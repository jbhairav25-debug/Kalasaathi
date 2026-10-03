"""Evaluate the saved five-class model on the training script's validation split."""

from __future__ import annotations

import argparse
import random
import shutil
from collections.abc import Callable
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont, UnidentifiedImageError

CLASS_NAMES = ("basket", "pot", "saree", "toy", "cloth")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
IMAGE_SIZE = 224
IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
IMAGENET_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)
Predictor = Callable[[np.ndarray], np.ndarray]


def validation_samples(
    dataset_dir: Path,
    validation_fraction: float,
    seed: int,
) -> list[tuple[Path, int]]:
    """Reproduce build_splits() from train_craft_classifier.py exactly."""
    if not dataset_dir.is_dir():
        raise FileNotFoundError(f"Dataset folder does not exist: {dataset_dir}")

    validation: list[tuple[Path, int]] = []
    randomizer = random.Random(seed)
    for label, class_name in enumerate(CLASS_NAMES):
        class_dir = dataset_dir / class_name
        if not class_dir.is_dir():
            raise FileNotFoundError(f"Missing class folder: {class_dir}")
        image_paths = sorted(
            path
            for path in class_dir.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        )
        if len(image_paths) < 2:
            raise ValueError(
                f"At least 2 images are required in {class_dir} "
                "to create a validation split."
            )
        randomizer.shuffle(image_paths)
        validation_count = max(1, round(len(image_paths) * validation_fraction))
        validation_count = min(validation_count, len(image_paths) - 1)
        validation.extend(
            (path, label) for path in image_paths[:validation_count]
        )
    return validation


def preprocess(image_path: Path) -> np.ndarray:
    try:
        with Image.open(image_path) as source:
            image = source.convert("RGB").resize(
                (IMAGE_SIZE, IMAGE_SIZE), Image.Resampling.BILINEAR
            )
            pixels = np.asarray(image, dtype=np.float32) / 255.0
    except (UnidentifiedImageError, OSError) as error:
        raise ValueError(f"Could not read validation image: {image_path}") from error
    normalized = (pixels - IMAGENET_MEAN) / IMAGENET_STD
    return normalized.transpose(2, 0, 1)


def checkpoint_predictor(
    checkpoint_path: Path,
) -> tuple[Predictor, tuple[str, ...]]:
    import torch
    from torch import nn
    from torchvision import models

    checkpoint = torch.load(
        checkpoint_path, map_location="cpu", weights_only=True
    )
    checkpoint_classes = tuple(checkpoint.get("classes", ()))
    if checkpoint_classes != CLASS_NAMES:
        raise ValueError(
            f"Checkpoint class order {checkpoint_classes!r} does not match "
            f"expected order {CLASS_NAMES!r}."
        )

    model = models.mobilenet_v3_small(weights=None)
    final_layer = model.classifier[3]
    if not isinstance(final_layer, nn.Linear):
        raise RuntimeError("Unexpected MobileNetV3-Small classifier structure")
    model.classifier[3] = nn.Linear(final_layer.in_features, len(CLASS_NAMES))
    model.load_state_dict(checkpoint["state_dict"])
    model.eval()

    def predict(batch: np.ndarray) -> np.ndarray:
        with torch.inference_mode():
            logits = model(torch.from_numpy(batch))
            return logits.argmax(dim=1).cpu().numpy()

    return predict, CLASS_NAMES


def onnx_predictor(
    model_path: Path,
    labels_path: Path,
) -> tuple[Predictor, tuple[str, ...]]:
    import onnxruntime as ort

    labels = tuple(
        line.strip()
        for line in labels_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    )
    if labels != CLASS_NAMES:
        raise ValueError(
            f"ONNX label order {labels!r} does not match expected order "
            f"{CLASS_NAMES!r}."
        )

    session = ort.InferenceSession(
        str(model_path), providers=["CPUExecutionProvider"]
    )
    input_name = session.get_inputs()[0].name

    def predict(batch: np.ndarray) -> np.ndarray:
        scores = session.run(None, {input_name: batch})[0]
        if scores.ndim != 2 or scores.shape[1] != len(CLASS_NAMES):
            raise RuntimeError(
                f"Expected model output with 5 classes; got shape {scores.shape}"
            )
        return np.argmax(scores, axis=1)

    return predict, labels


def print_results(matrix: np.ndarray, total: int) -> None:
    correct = int(np.trace(matrix))
    print(f"\nOverall accuracy: {correct}/{total} ({correct / total:.1%})")
    print("\nPer-class accuracy (recall):")
    for index, class_name in enumerate(CLASS_NAMES):
        support = int(matrix[index].sum())
        class_correct = int(matrix[index, index])
        accuracy = class_correct / support if support else 0.0
        print(
            f"  {class_name}: {class_correct}/{support} "
            f"({accuracy:.1%})"
        )

    print("\nConfusion matrix (rows = actual, columns = predicted):")
    label_width = max(len(name) for name in CLASS_NAMES)
    column_width = max(7, label_width + 1)
    print(" " * (label_width + 3) + "".join(
        f"{name:>{column_width}}" for name in CLASS_NAMES
    ))
    for class_name, row in zip(CLASS_NAMES, matrix, strict=True):
        print(
            f"{class_name:>{label_width}} |"
            + "".join(f"{int(value):>{column_width}}" for value in row)
        )

    confusions = [
        (int(matrix[actual, predicted]), CLASS_NAMES[actual], CLASS_NAMES[predicted])
        for actual in range(len(CLASS_NAMES))
        for predicted in range(len(CLASS_NAMES))
        if actual != predicted and matrix[actual, predicted] > 0
    ]
    print("\nMisclassified validation images:")
    if not confusions:
        print("  None")
    else:
        for count, actual, predicted in sorted(confusions, reverse=True):
            print(f"  {actual} predicted as {predicted}: {count}")


def copy_misclassified(
    errors: list[tuple[Path, str, str]],
    dataset_dir: Path,
    output_dir: Path,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    print("\nMisclassified validation image files:")
    if not errors:
        print("  None")
        return

    for source, actual, predicted in errors:
        relative_source = source.relative_to(dataset_dir)
        print(f"  {actual} -> {predicted}: dataset/{relative_source.as_posix()}")
        destination_name = (
            f"{source.stem}__actual-{actual}__pred-{predicted}{source.suffix}"
        )
        destination = output_dir / destination_name
        suffix = 2
        while destination.exists():
            destination = output_dir / (
                f"{source.stem}__actual-{actual}__pred-{predicted}"
                f"__{suffix}{source.suffix}"
            )
            suffix += 1
        shutil.copy2(source, destination)


def save_confusion_matrix(matrix: np.ndarray, output_path: Path) -> None:
    cell_size = 112
    left_margin = 138
    top_margin = 105
    right_margin = 24
    bottom_margin = 32
    width = left_margin + cell_size * len(CLASS_NAMES) + right_margin
    height = top_margin + cell_size * len(CLASS_NAMES) + bottom_margin
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()

    draw.text((left_margin, 16), "Confusion Matrix", fill="black", font=font)
    draw.text(
        (left_margin, 34),
        "Rows = actual class; columns = predicted class",
        fill="black",
        font=font,
    )
    draw.text((8, 70), "ACTUAL", fill="black", font=font)
    draw.text((left_margin, 70), "PREDICTED", fill="black", font=font)

    maximum = max(1, int(matrix.max()))
    for index, class_name in enumerate(CLASS_NAMES):
        draw.text(
            (left_margin + index * cell_size + 8, top_margin - 20),
            class_name,
            fill="black",
            font=font,
        )
        draw.text(
            (8, top_margin + index * cell_size + cell_size // 2 - 4),
            class_name,
            fill="black",
            font=font,
        )
        for predicted_index in range(len(CLASS_NAMES)):
            count = int(matrix[index, predicted_index])
            intensity = count / maximum
            fill = (
                int(245 - 105 * intensity),
                int(248 - 70 * intensity),
                255,
            )
            x0 = left_margin + predicted_index * cell_size
            y0 = top_margin + index * cell_size
            draw.rectangle(
                (x0, y0, x0 + cell_size, y0 + cell_size),
                fill=fill,
                outline="#808080",
                width=1,
            )
            text = str(count)
            bounds = draw.textbbox((0, 0), text, font=font)
            text_x = x0 + (cell_size - (bounds[2] - bounds[0])) // 2
            text_y = y0 + (cell_size - (bounds[3] - bounds[1])) // 2
            draw.text((text_x, text_y), text, fill="black", font=font)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path)


def parse_args() -> argparse.Namespace:
    backend_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description="Evaluate the KalaSaathi craft classifier on its held-out set."
    )
    parser.add_argument(
        "--model",
        choices=("auto", "checkpoint", "onnx"),
        default="auto",
        help="auto prefers the best PyTorch checkpoint, then uses the ONNX export.",
    )
    parser.add_argument(
        "--dataset",
        type=Path,
        default=backend_dir / "dataset",
    )
    parser.add_argument(
        "--checkpoint",
        type=Path,
        default=backend_dir / "training-output" / "craft_classifier_v2_best.pth",
    )
    parser.add_argument(
        "--onnx",
        type=Path,
        default=backend_dir / "models" / "kala_craft_classifier_v2.onnx",
    )
    parser.add_argument(
        "--labels",
        type=Path,
        default=backend_dir / "models" / "kala_craft_classes_v2.txt",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=backend_dir / "training-output" / "confusion_matrix_v2.png",
    )
    parser.add_argument(
        "--misclassified-dir",
        type=Path,
        default=backend_dir / "training-output" / "misclassified_v2",
        help="Folder to receive copies of misclassified validation images.",
    )
    parser.add_argument("--validation-fraction", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--batch-size", type=int, default=8)
    args = parser.parse_args()
    if not 0 < args.validation_fraction < 1:
        parser.error("--validation-fraction must be between 0 and 1")
    if args.batch_size < 1:
        parser.error("--batch-size must be at least 1")
    return args


def main() -> None:
    args = parse_args()
    checkpoint_path = args.checkpoint
    model_path = args.onnx

    if args.model == "checkpoint":
        if not checkpoint_path.is_file():
            raise FileNotFoundError(f"Checkpoint not found: {checkpoint_path}")
        predict, labels = checkpoint_predictor(checkpoint_path)
        model_used = checkpoint_path
    elif args.model == "onnx":
        if not model_path.is_file():
            raise FileNotFoundError(f"ONNX model not found: {model_path}")
        predict, labels = onnx_predictor(model_path, args.labels)
        model_used = model_path
    elif checkpoint_path.is_file():
        predict, labels = checkpoint_predictor(checkpoint_path)
        model_used = checkpoint_path
    elif model_path.is_file():
        predict, labels = onnx_predictor(model_path, args.labels)
        model_used = model_path
    else:
        raise FileNotFoundError(
            "No trained model found. Expected either "
            f"{checkpoint_path} or {model_path}."
        )

    validation = validation_samples(
        args.dataset, args.validation_fraction, args.seed
    )
    matrix = np.zeros((len(CLASS_NAMES), len(CLASS_NAMES)), dtype=np.int64)
    errors: list[tuple[Path, str, str]] = []
    for start in range(0, len(validation), args.batch_size):
        batch_samples = validation[start : start + args.batch_size]
        batch = np.stack([preprocess(path) for path, _ in batch_samples])
        predictions = predict(batch)
        for (path, actual), predicted in zip(
            batch_samples, predictions, strict=True
        ):
            predicted_index = int(predicted)
            matrix[actual, predicted_index] += 1
            if predicted_index != actual:
                errors.append(
                    (path, CLASS_NAMES[actual], CLASS_NAMES[predicted_index])
                )

    print(f"Model: {model_used}")
    print(f"Validation images: {len(validation)}")
    print(f"Class order: {', '.join(labels)}")
    print_results(matrix, len(validation))
    copy_misclassified(errors, args.dataset, args.misclassified_dir)
    print(f"\nMisclassified image copies saved to: {args.misclassified_dir}")
    save_confusion_matrix(matrix, args.output)
    print(f"\nConfusion matrix image saved to: {args.output}")


if __name__ == "__main__":
    main()
