"""Read-only image integrity audit and contact-sheet generator."""

from __future__ import annotations

import hashlib
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps, UnidentifiedImageError

ROOT = Path(__file__).resolve().parent / "dataset"
PREVIEW_DIR = ROOT / "audit_previews"
CLASSES = ("basket", "pot", "saree", "toy", "cloth")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".gif", ".tif", ".tiff"}
THUMBNAIL_SIZE = (180, 140)
CELL_SIZE = (200, 175)
COLUMNS = 4
TINY_DIMENSION = 128


def image_files(folder: Path) -> list[Path]:
    if not folder.is_dir():
        return []
    return sorted(
        (
            path
            for path in folder.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        ),
        key=lambda path: path.name.lower(),
    )


def inspect_image(path: Path) -> tuple[int, int] | None:
    try:
        with Image.open(path) as image:
            image.verify()
        with Image.open(path) as image:
            return image.size
    except (UnidentifiedImageError, OSError, ValueError, Image.DecompressionBombError):
        return None


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def make_contact_sheet(
    class_name: str,
    valid_images: list[tuple[Path, tuple[int, int]]],
    corrupt_images: list[Path],
) -> Path:
    items: list[tuple[Path | None, tuple[int, int] | None]] = [
        (path, dimensions) for path, dimensions in valid_images
    ]
    items.extend((path, None) for path in corrupt_images)
    if not items:
        items = [(None, None)]

    rows = (len(items) + COLUMNS - 1) // COLUMNS
    sheet = Image.new(
        "RGB",
        (COLUMNS * CELL_SIZE[0], rows * CELL_SIZE[1]),
        color="white",
    )
    draw = ImageDraw.Draw(sheet)

    for index, (path, dimensions) in enumerate(items):
        column = index % COLUMNS
        row = index // COLUMNS
        left = column * CELL_SIZE[0]
        top = row * CELL_SIZE[1]
        image_box = (
            left + (CELL_SIZE[0] - THUMBNAIL_SIZE[0]) // 2,
            top + 5,
            left + (CELL_SIZE[0] + THUMBNAIL_SIZE[0]) // 2,
            top + 5 + THUMBNAIL_SIZE[1],
        )

        if path is not None and dimensions is not None:
            try:
                with Image.open(path) as image:
                    preview = ImageOps.contain(
                        image.convert("RGB"), THUMBNAIL_SIZE
                    )
                image_left = image_box[0] + (THUMBNAIL_SIZE[0] - preview.width) // 2
                image_top = image_box[1] + (THUMBNAIL_SIZE[1] - preview.height) // 2
                sheet.paste(preview, (image_left, image_top))
                caption = f"{path.name} ({dimensions[0]}x{dimensions[1]})"
            except (UnidentifiedImageError, OSError, ValueError):
                caption = f"{path.name} (preview unavailable)"
        elif path is not None:
            draw.rectangle(image_box, fill="#f3cccc")
            caption = f"{path.name} (CORRUPT)"
        else:
            draw.rectangle(image_box, fill="#eeeeee")
            caption = "No image files found"

        draw.text((left + 5, top + 150), caption[:30], fill="black")

    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    output_path = PREVIEW_DIR / f"{class_name}_contact_sheet.jpg"
    sheet.save(output_path, quality=88)
    return output_path


def audit_class(class_name: str) -> tuple[list[tuple[Path, tuple[int, int]]], list[Path]]:
    folder = ROOT / class_name
    candidates = image_files(folder)
    valid: list[tuple[Path, tuple[int, int]]] = []
    corrupt: list[Path] = []

    print(f"\n[{class_name}] {folder}")
    if not folder.is_dir():
        print("  ERROR: class folder does not exist")

    for path in candidates:
        dimensions = inspect_image(path)
        if dimensions is None:
            corrupt.append(path)
            print(f"  CORRUPT: {path.name} (unreadable image)")
            continue
        valid.append((path, dimensions))
        tiny = min(dimensions) < TINY_DIMENSION
        marker = "  TINY" if tiny else ""
        print(f"  {path.name}: {dimensions[0]}x{dimensions[1]}{marker}")

    print(
        f"  Summary: {len(candidates)} image files, "
        f"{len(valid)} valid, {len(corrupt)} unreadable"
    )
    return valid, corrupt


def main() -> None:
    hashes: dict[str, list[Path]] = defaultdict(list)
    audit_results: dict[
        str, tuple[list[tuple[Path, tuple[int, int]]], list[Path]]
    ] = {}

    for class_name in CLASSES:
        valid, corrupt = audit_class(class_name)
        audit_results[class_name] = (valid, corrupt)
        for path in image_files(ROOT / class_name):
            try:
                hashes[sha256(path)].append(path)
            except OSError as error:
                print(f"  HASH ERROR: {path}: {error}")

    print("\nExact duplicate files (SHA-256):")
    duplicate_groups = [paths for paths in hashes.values() if len(paths) > 1]
    if duplicate_groups:
        for paths in duplicate_groups:
            print("  " + " = ".join(str(path.relative_to(ROOT)) for path in paths))
    else:
        print("  None found")

    print("\nContact sheets:")
    for class_name in CLASSES:
        valid, corrupt = audit_results[class_name]
        output_path = make_contact_sheet(class_name, valid, corrupt)
        print(f"  {class_name}: {output_path}")

    print("\nAudit complete. Dataset images were not changed.")


if __name__ == "__main__":
    main()
