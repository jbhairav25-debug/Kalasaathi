"""Train and export a five-class KalaSaathi craft image classifier."""

from __future__ import annotations

import argparse
import random
from pathlib import Path
from typing import Any

import onnx
import numpy as np
import torch
from PIL import Image, UnidentifiedImageError
from torch import nn
from torch.utils.data import DataLoader, Dataset, WeightedRandomSampler
from torchvision import models, transforms

CLASS_NAMES = ("basket", "pot", "saree", "toy", "cloth")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
IMAGE_SIZE = 224
IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)
FINE_TUNE_FEATURE_BLOCKS = 2


class CraftImageDataset(Dataset):
    def __init__(
        self,
        samples: list[tuple[Path, int]],
        image_transform: transforms.Compose,
    ) -> None:
        self.samples = samples
        self.image_transform = image_transform

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> tuple[torch.Tensor, int]:
        image_path, label = self.samples[index]
        try:
            with Image.open(image_path) as image:
                image_tensor = self.image_transform(image.convert("RGB"))
        except (OSError, UnidentifiedImageError) as error:
            raise RuntimeError(f"Could not read training image: {image_path}") from error
        return image_tensor, label


def build_splits(
    dataset_dir: Path,
    validation_fraction: float,
    seed: int,
) -> tuple[list[tuple[Path, int]], list[tuple[Path, int]]]:
    if not dataset_dir.is_dir():
        raise FileNotFoundError(f"Dataset folder does not exist: {dataset_dir}")

    train_samples: list[tuple[Path, int]] = []
    validation_samples: list[tuple[Path, int]] = []
    randomizer = random.Random(seed)

    for label, class_name in enumerate(CLASS_NAMES):
        class_dir = dataset_dir / class_name
        if not class_dir.is_dir():
            raise FileNotFoundError(
                f"Missing class folder: {class_dir}. "
                f"Create one folder for each of: {', '.join(CLASS_NAMES)}"
            )

        image_paths = sorted(
            path
            for path in class_dir.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        )
        if len(image_paths) < 2:
            raise ValueError(
                f"Add at least 2 images to {class_dir}; "
                "each class needs training and validation images."
            )

        randomizer.shuffle(image_paths)
        validation_count = max(1, round(len(image_paths) * validation_fraction))
        validation_count = min(validation_count, len(image_paths) - 1)
        validation_paths = image_paths[:validation_count]
        training_paths = image_paths[validation_count:]

        train_samples.extend((path, label) for path in training_paths)
        validation_samples.extend((path, label) for path in validation_paths)
        print(
            f"{class_name}: {len(training_paths)} training, "
            f"{len(validation_paths)} validation"
        )

    return train_samples, validation_samples


def create_model() -> nn.Module:
    model = models.mobilenet_v3_small(
        weights=models.MobileNet_V3_Small_Weights.DEFAULT
    )
    for parameter in model.features.parameters():
        parameter.requires_grad = False
    for block in model.features[-FINE_TUNE_FEATURE_BLOCKS:]:
        for parameter in block.parameters():
            parameter.requires_grad = True
    for parameter in model.classifier[0].parameters():
        parameter.requires_grad = False

    final_layer = model.classifier[3]
    if not isinstance(final_layer, nn.Linear):
        raise RuntimeError("Unexpected MobileNetV3-Small classifier structure")
    model.classifier[3] = nn.Linear(final_layer.in_features, len(CLASS_NAMES))
    return model


def evaluate(
    model: nn.Module,
    batches: DataLoader,
    loss_function: nn.Module,
    device: torch.device,
) -> tuple[float, float]:
    model.eval()
    total_loss = 0.0
    correct = 0
    total = 0
    with torch.inference_mode():
        for images, labels in batches:
            images = images.to(device)
            labels = labels.to(device)
            logits = model(images)
            total_loss += loss_function(logits, labels).item() * labels.size(0)
            correct += (logits.argmax(dim=1) == labels).sum().item()
            total += labels.size(0)
    return total_loss / total, correct / total


def build_training_sampler(
    samples: list[tuple[Path, int]],
    seed: int,
) -> tuple[WeightedRandomSampler | None, bool, torch.Generator, np.ndarray]:
    class_counts = np.bincount(
        [label for _, label in samples], minlength=len(CLASS_NAMES)
    )
    if np.any(class_counts == 0):
        raise ValueError("Every class needs at least one training image.")

    generator = torch.Generator().manual_seed(seed)
    if len(set(class_counts.tolist())) > 1:
        sample_weights = torch.tensor(
            [1.0 / class_counts[label] for _, label in samples],
            dtype=torch.double,
        )
        sampler = WeightedRandomSampler(
            sample_weights,
            num_samples=len(samples),
            replacement=True,
            generator=generator,
        )
        shuffle = False
    else:
        sampler = None
        shuffle = True
    return sampler, shuffle, generator, class_counts


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train a MobileNetV3-Small craft classifier from backend/dataset."
    )
    parser.add_argument(
        "--dataset",
        type=Path,
        default=Path(__file__).resolve().parent / "dataset",
        help="Folder containing one subfolder per craft class.",
    )
    parser.add_argument("--epochs", type=int, default=40)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--validation-fraction", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--patience", type=int, default=7)
    parser.add_argument("--min-delta", type=float, default=0.001)
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parent / "models",
        help="Folder for the ONNX model and ordered class labels.",
    )
    parser.add_argument(
        "--checkpoint-dir",
        type=Path,
        default=Path(__file__).resolve().parent / "training-output",
        help="Folder for this run's best PyTorch checkpoint.",
    )
    parser.add_argument(
        "--checkpoint-name",
        default="craft_classifier_v2_best.pth",
        help="Checkpoint filename; defaults to a new name to preserve prior runs.",
    )
    parser.add_argument(
        "--model-name",
        default="kala_craft_classifier_v2.onnx",
        help="ONNX filename; defaults to a new name to preserve prior models.",
    )
    parser.add_argument(
        "--labels-name",
        default="kala_craft_classes_v2.txt",
        help="Ordered class-label filename for this exported model.",
    )
    args = parser.parse_args()
    if args.epochs < 1:
        parser.error("--epochs must be at least 1")
    if args.batch_size < 1:
        parser.error("--batch-size must be at least 1")
    if args.patience < 1:
        parser.error("--patience must be at least 1")
    if args.min_delta < 0:
        parser.error("--min-delta cannot be negative")
    if not 0 < args.validation_fraction < 1:
        parser.error("--validation-fraction must be between 0 and 1")
    return args


def main() -> None:
    args = parse_args()
    random.seed(args.seed)
    np.random.seed(args.seed)
    torch.manual_seed(args.seed)
    torch.set_num_threads(min(4, torch.get_num_threads()))
    device = torch.device("cpu")
    print(f"Training on CPU with {torch.get_num_threads()} threads")

    train_samples, validation_samples = build_splits(
        args.dataset, args.validation_fraction, args.seed
    )
    training_transform = transforms.Compose(
        [
            transforms.RandomResizedCrop(
                IMAGE_SIZE,
                scale=(0.75, 1.0),
                ratio=(0.85, 1.15),
            ),
            transforms.RandomHorizontalFlip(p=0.5),
            transforms.RandomRotation(degrees=8),
            transforms.ColorJitter(
                brightness=0.15,
                contrast=0.15,
                saturation=0.15,
                hue=0.03,
            ),
            transforms.ToTensor(),
            transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        ]
    )
    validation_transform = transforms.Compose(
        [
            transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
            transforms.ToTensor(),
            transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
        ]
    )
    sampler, shuffle, loader_generator, class_counts = build_training_sampler(
        train_samples, args.seed
    )
    if sampler is not None:
        print(f"Using class-balanced sampling; training counts: {class_counts.tolist()}")
    else:
        print(f"Classes are balanced; using seeded shuffle: {class_counts.tolist()}")

    train_loader = DataLoader(
        CraftImageDataset(train_samples, training_transform),
        batch_size=args.batch_size,
        shuffle=shuffle,
        sampler=sampler,
        generator=loader_generator,
        num_workers=0,
    )
    validation_loader = DataLoader(
        CraftImageDataset(validation_samples, validation_transform),
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=0,
    )

    model = create_model().to(device)
    total_parameters = sum(parameter.numel() for parameter in model.parameters())
    trainable_parameters = sum(
        parameter.numel()
        for parameter in model.parameters()
        if parameter.requires_grad
    )
    print(
        f"Trainable parameters: {trainable_parameters:,}/{total_parameters:,} "
        f"({trainable_parameters / total_parameters:.1%}); "
        f"{total_parameters - trainable_parameters:,} remain frozen"
    )
    loss_function = nn.CrossEntropyLoss()
    optimizer = torch.optim.AdamW(
        [
            {
                "params": [
                    parameter
                    for parameter in model.features.parameters()
                    if parameter.requires_grad
                ],
                "lr": 0.0001,
            },
            {
                "params": [
                    parameter
                    for parameter in model.classifier.parameters()
                    if parameter.requires_grad
                ],
                "lr": 0.0005,
            },
        ],
        weight_decay=0.0001,
    )
    args.checkpoint_dir.mkdir(parents=True, exist_ok=True)
    checkpoint_path = args.checkpoint_dir / args.checkpoint_name
    best_accuracy = -1.0
    best_loss = float("inf")
    stopping_best_accuracy = -1.0
    stopping_best_loss = float("inf")
    best_epoch = 0
    epochs_without_improvement = 0

    for epoch in range(1, args.epochs + 1):
        model.train()
        for module in model.features.modules():
            if isinstance(module, nn.BatchNorm2d):
                module.eval()
        model.classifier.train()
        training_loss = 0.0
        training_total = 0
        for images, labels in train_loader:
            images = images.to(device)
            labels = labels.to(device)
            optimizer.zero_grad(set_to_none=True)
            logits = model(images)
            loss = loss_function(logits, labels)
            loss.backward()
            optimizer.step()
            training_loss += loss.item() * labels.size(0)
            training_total += labels.size(0)

        validation_loss, validation_accuracy = evaluate(
            model, validation_loader, loss_function, device
        )
        print(
            f"Epoch {epoch:02d}/{args.epochs}: "
            f"train_loss={training_loss / training_total:.4f}, "
            f"val_loss={validation_loss:.4f}, "
            f"val_accuracy={validation_accuracy:.1%}"
        )
        is_best_checkpoint = (
            validation_accuracy > best_accuracy
            or (
                validation_accuracy == best_accuracy
                and validation_loss < best_loss
            )
        )
        if is_best_checkpoint:
            best_accuracy = validation_accuracy
            best_loss = validation_loss
            best_epoch = epoch
            torch.save(
                {
                    "state_dict": model.state_dict(),
                    "classes": list(CLASS_NAMES),
                    "validation_accuracy": best_accuracy,
                    "validation_loss": best_loss,
                    "epoch": best_epoch,
                    "seed": args.seed,
                },
                checkpoint_path,
            )

        loss_improved = (
            validation_loss < stopping_best_loss - args.min_delta
        )
        accuracy_improved = validation_accuracy > stopping_best_accuracy
        if loss_improved or accuracy_improved:
            stopping_best_loss = min(stopping_best_loss, validation_loss)
            stopping_best_accuracy = max(
                stopping_best_accuracy, validation_accuracy
            )
            epochs_without_improvement = 0
        else:
            epochs_without_improvement += 1
            print(
                f"  No validation loss/accuracy improvement for "
                f"{epochs_without_improvement}/{args.patience} epochs"
            )
            if epochs_without_improvement >= args.patience:
                print(f"Early stopping at epoch {epoch}.")
                break

    checkpoint: dict[str, Any] = torch.load(
        checkpoint_path, map_location=device, weights_only=True
    )
    model.load_state_dict(checkpoint["state_dict"])
    model.eval()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    onnx_path = args.output_dir / args.model_name
    labels_path = args.output_dir / args.labels_name
    example_input = torch.zeros(1, 3, IMAGE_SIZE, IMAGE_SIZE, device=device)
    torch.onnx.export(
        model,
        example_input,
        str(onnx_path),
        input_names=["input"],
        output_names=["logits"],
        dynamic_axes={"input": {0: "batch_size"}, "logits": {0: "batch_size"}},
        opset_version=17,
        dynamo=False,
    )
    onnx.checker.check_model(str(onnx_path))
    labels_path.write_text("\n".join(CLASS_NAMES) + "\n", encoding="utf-8")
    print(
        f"Best validation accuracy: {best_accuracy:.1%} "
        f"(val_loss={best_loss:.4f}, epoch {best_epoch})\n"
        f"ONNX model: {onnx_path}\n"
        f"Class order: {labels_path}\n"
        f"PyTorch checkpoint: {checkpoint_path}"
    )


if __name__ == "__main__":
    main()
