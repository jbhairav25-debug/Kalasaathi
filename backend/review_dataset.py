"""Create class-by-class review copies and source/license reports."""

from __future__ import annotations

import csv
import filecmp
import shutil
from pathlib import Path

DATASET_DIR = Path(__file__).resolve().parent / "dataset"
CLASS_NAMES = ("basket", "pot", "saree", "toy", "cloth")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".gif", ".tif", ".tiff"}
REPORT_FIELDS = (
    "filename",
    "commons_title",
    "source_url",
    "author",
    "license",
    "source_status",
)


def load_sources(class_dir: Path) -> tuple[dict[str, dict[str, str]], bool]:
    sources_path = class_dir / "sources.csv"
    if not sources_path.is_file():
        return {}, False

    with sources_path.open("r", newline="", encoding="utf-8-sig") as source_file:
        reader = csv.DictReader(source_file)
        if not reader.fieldnames or "local_file" not in reader.fieldnames:
            raise ValueError(
                f"{sources_path} must contain a 'local_file' column."
            )
        rows = {
            (row.get("local_file") or "").strip(): {
                key: (value or "").strip() for key, value in row.items() if key
            }
            for row in reader
            if (row.get("local_file") or "").strip()
        }
    return rows, True


def review_class(class_name: str) -> None:
    class_dir = DATASET_DIR / class_name
    if not class_dir.is_dir():
        print(f"[{class_name}] ERROR: dataset folder not found: {class_dir}")
        return

    image_paths = sorted(
        (
            path
            for path in class_dir.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        ),
        key=lambda path: path.name.lower(),
    )
    sources, has_manifest = load_sources(class_dir)
    review_dir = DATASET_DIR / f"review_{class_name}"
    review_dir.mkdir(parents=True, exist_ok=True)

    report_rows: list[dict[str, str]] = []
    copied = 0
    for source in image_paths:
        destination = review_dir / source.name
        if destination.exists():
            if destination.is_file() and source.samefile(destination):
                pass
            elif destination.is_file() and filecmp.cmp(
                source, destination, shallow=False
            ):
                print(f"  Existing review copy retained: {destination.name}")
            else:
                raise FileExistsError(
                    f"Refusing to overwrite a different review file: {destination}"
                )
        else:
            shutil.copy2(source, destination)
            copied += 1

        attribution = sources.get(source.name)
        if attribution is None:
            status = (
                "sources.csv missing"
                if not has_manifest
                else "no matching filename in sources.csv"
            )
            report_rows.append(
                {
                    "filename": source.name,
                    "commons_title": "",
                    "source_url": "",
                    "author": "",
                    "license": "",
                    "source_status": status,
                }
            )
        else:
            report_rows.append(
                {
                    "filename": source.name,
                    "commons_title": attribution.get("commons_title", ""),
                    "source_url": attribution.get("source_url", ""),
                    "author": attribution.get("author", ""),
                    "license": attribution.get("license", ""),
                    "source_status": "listed in sources.csv",
                }
            )

    report_path = review_dir / "review_report.csv"
    with report_path.open("w", newline="", encoding="utf-8-sig") as report_file:
        writer = csv.DictWriter(report_file, fieldnames=REPORT_FIELDS)
        writer.writeheader()
        writer.writerows(report_rows)

    missing_attribution = sum(
        row["source_status"] != "listed in sources.csv" for row in report_rows
    )
    print(
        f"[{class_name}] {len(image_paths)} images; {copied} new review copies; "
        f"{missing_attribution} images without source-manifest attribution"
    )
    print(f"  Review folder: {review_dir}")
    print(f"  Report: {report_path}")


def main() -> None:
    if not DATASET_DIR.is_dir():
        raise FileNotFoundError(f"Dataset folder does not exist: {DATASET_DIR}")

    print("Creating read-only dataset review copies and attribution reports.")
    print("Original dataset images will not be modified.")
    for class_name in CLASS_NAMES:
        try:
            review_class(class_name)
        except (OSError, csv.Error, ValueError) as error:
            print(f"[{class_name}] ERROR: {error}")
    print("\nReview preparation complete.")


if __name__ == "__main__":
    main()
