"""Download a small, resumable craft-image set from Wikimedia Commons only."""

import csv
import io
import re
import time
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.parse import quote

import requests
from PIL import Image, UnidentifiedImageError

API = "https://commons.wikimedia.org/w/api.php"
ROOT = Path(__file__).resolve().parent / "dataset"
PER_CLASS = 20
MIN_REQUEST_INTERVAL = 3.0
MAX_RETRIES = 5
RETRY_BASE_SECONDS = 5.0
USER_AGENT = (
    "KalaSaathiDatasetDownloader/2.0 "
    "(Python requests; https://commons.wikimedia.org/wiki/Commons:API)"
)
CATEGORIES = {
    "basket": ["Basketry in India", "Baskets of India"],
    "pot": ["Pottery in India", "Pottery from India"],
    "saree": ["Saris from India", "Sari fabric"],
    "toy": [
        "Wooden toys of India",
        "Channapatna toys",
        "Nirmal toys and craft",
        "Traditional toys of India",
    ],
    "cloth": ["Textiles of India", "Handlooms in India"],
}
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".tif", ".tiff"}
CSV_HEADER = ["local_file", "commons_title", "source_url", "author", "license"]
_LAST_REQUEST_AT: float | None = None


def _wait_for_request_slot() -> None:
    global _LAST_REQUEST_AT
    if _LAST_REQUEST_AT is not None:
        elapsed = time.monotonic() - _LAST_REQUEST_AT
        if elapsed < MIN_REQUEST_INTERVAL:
            time.sleep(MIN_REQUEST_INTERVAL - elapsed)
    _LAST_REQUEST_AT = time.monotonic()


def _retry_after_seconds(response: requests.Response, retry_number: int) -> float:
    retry_after = response.headers.get("Retry-After", "").strip()
    if retry_after:
        try:
            requested_delay = float(retry_after)
        except ValueError:
            try:
                retry_at = parsedate_to_datetime(retry_after)
                if retry_at.tzinfo is None:
                    retry_at = retry_at.replace(tzinfo=timezone.utc)
                requested_delay = (
                    retry_at - datetime.now(timezone.utc)
                ).total_seconds()
            except (TypeError, ValueError, OverflowError):
                requested_delay = 0.0
        else:
            requested_delay = max(0.0, requested_delay)
    else:
        requested_delay = 0.0
    backoff = RETRY_BASE_SECONDS * (2**retry_number)
    return max(requested_delay, backoff)


def _get(url: str, *, params: dict | None = None, timeout: int) -> requests.Response:
    for retry_number in range(MAX_RETRIES + 1):
        _wait_for_request_slot()
        response = requests.get(
            url,
            params=params,
            timeout=timeout,
            headers={"User-Agent": USER_AGENT},
        )
        if response.status_code != 429:
            response.raise_for_status()
            return response

        if retry_number == MAX_RETRIES:
            response.raise_for_status()
        delay = _retry_after_seconds(response, retry_number)
        response.close()
        print(
            f"  Wikimedia rate limit (HTTP 429); "
            f"retrying in {delay:.0f} seconds "
            f"({retry_number + 1}/{MAX_RETRIES})"
        )
        time.sleep(delay)

    raise RuntimeError("Wikimedia request exhausted its retry attempts")


def api_get(params: dict) -> dict:
    request_params = dict(params)
    request_params["format"] = "json"
    return _get(API, params=request_params, timeout=30).json()


def category_members(category: str, max_files: int = 250, max_depth: int = 2) -> list[str]:
    """Collect image file titles from a Commons category and its subcategories."""
    found: list[str] = []
    seen_categories: set[str] = set()
    queue = [(category, 0)]

    while queue and len(found) < max_files:
        current, depth = queue.pop(0)
        if current in seen_categories or depth > max_depth:
            continue
        seen_categories.add(current)
        continuation: dict = {}
        while True:
            params = {
                "action": "query",
                "list": "categorymembers",
                "cmtitle": f"Category:{current}",
                "cmtype": "file|subcat",
                "cmlimit": "max",
            }
            params.update(continuation)
            data = api_get(params)

            for item in data.get("query", {}).get("categorymembers", []):
                title = item.get("title", "")
                if item.get("ns") == 6:
                    if Path(title).suffix.lower() in IMAGE_EXTENSIONS and title not in found:
                        found.append(title)
                        if len(found) >= max_files:
                            break
                elif item.get("ns") == 14 and depth < max_depth:
                    subcategory = title.removeprefix("Category:")
                    if subcategory not in seen_categories:
                        queue.append((subcategory, depth + 1))

            if len(found) >= max_files or "continue" not in data:
                break
            continuation = data["continue"]

    return found


def file_info(titles: list[str]) -> list[dict[str, str]]:
    """Get Commons file URLs and attribution metadata in paced batches."""
    results: list[dict[str, str]] = []
    for start in range(0, len(titles), 20):
        batch = titles[start : start + 20]
        try:
            data = api_get(
                {
                    "action": "query",
                    "prop": "imageinfo",
                    "titles": "|".join(batch),
                    "iiprop": "url|extmetadata",
                    "iiurlwidth": "900",
                }
            )
        except Exception as error:
            print(f"  Could not retrieve image metadata batch: {error}")
            continue

        for page in data.get("query", {}).get("pages", {}).values():
            info = (page.get("imageinfo") or [{}])[0]
            if not info.get("thumburl") and not info.get("url"):
                continue
            metadata = info.get("extmetadata", {})

            def metadata_value(name: str) -> str:
                value = metadata.get(name, {}).get("value", "")
                return re.sub(r"<[^>]+>", "", value).strip()

            title = page.get("title", "")
            results.append(
                {
                    "title": title,
                    "url": info.get("url", ""),
                    "download_url": info.get("thumburl") or info.get("url", ""),
                    "description_url": (
                        "https://commons.wikimedia.org/wiki/"
                        f"{quote(title.replace(' ', '_'))}"
                    ),
                    "author": metadata_value("Artist"),
                    "license": metadata_value("LicenseShortName"),
                }
            )
    return results


def _existing_images(folder: Path) -> list[Path]:
    return sorted(
        (
            path
            for path in folder.iterdir()
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        ),
        key=lambda path: path.name.lower(),
    )


def _next_filename(folder: Path, start_index: int, title: str) -> tuple[str, int]:
    extension = Path(title).suffix.lower()
    if extension not in IMAGE_EXTENSIONS or extension in {".tif", ".tiff"}:
        extension = ".jpg"
    index = start_index
    while True:
        filename = f"{index:03d}{extension}"
        if not (folder / filename).exists():
            return filename, index + 1
        index += 1


def _ensure_sources_file(csv_path: Path) -> None:
    if not csv_path.exists() or csv_path.stat().st_size == 0:
        with csv_path.open("w", newline="", encoding="utf-8-sig") as source_file:
            csv.writer(source_file).writerow(CSV_HEADER)


def _is_readable_image(content: bytes) -> bool:
    try:
        with Image.open(io.BytesIO(content)) as image:
            image.verify()
    except (UnidentifiedImageError, OSError):
        return False
    return True


def download_class(class_name: str, categories: list[str]) -> int:
    folder = ROOT / class_name
    folder.mkdir(parents=True, exist_ok=True)
    existing = _existing_images(folder)
    if len(existing) >= PER_CLASS:
        print(
            f"\n[{class_name}] already has {len(existing)} images; "
            f"skipping (target {PER_CLASS})"
        )
        return len(existing)

    remaining = PER_CLASS - len(existing)
    print(
        f"\n[{class_name}] has {len(existing)} images; "
        f"will download up to {remaining} more from Wikimedia Commons..."
    )
    titles: list[str] = []
    for category in categories:
        try:
            titles.extend(category_members(category, max_files=120, max_depth=2))
        except Exception as error:
            print(f"  Could not read {category}; continuing: {error}")
    titles = list(dict.fromkeys(titles))

    infos = file_info(titles[:100])
    csv_path = folder / "sources.csv"
    _ensure_sources_file(csv_path)
    numeric_stems = [
        int(path.stem) for path in existing if path.stem.isdigit()
    ]
    next_index = max(numeric_stems, default=0) + 1
    downloaded = 0

    for info in infos:
        if downloaded >= remaining:
            break
        url = info["download_url"]
        if not url:
            continue
        filename, next_index = _next_filename(folder, next_index, info["title"])
        destination = folder / filename
        try:
            response = _get(url, timeout=45)
            content_type = response.headers.get("Content-Type", "").lower()
            if not content_type.startswith("image/") or not _is_readable_image(
                response.content
            ):
                print(f"  skipped {info['title']}: response was not a readable image")
                continue
            destination.write_bytes(response.content)
            with csv_path.open("a", newline="", encoding="utf-8") as source_file:
                csv.writer(source_file).writerow(
                    [
                        filename,
                        info["title"],
                        info["description_url"],
                        info["author"],
                        info["license"],
                    ]
                )
                source_file.flush()
            downloaded += 1
            print(
                f"  downloaded {len(existing) + downloaded}/{PER_CLASS}: "
                f"{info['title']}"
            )
        except Exception as error:
            print(f"  skipped {info['title']}; continuing: {error}")

    total = len(_existing_images(folder))
    print(f"[{class_name}] finished: {total}/{PER_CLASS} images")
    return total


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    print("KalaSaathi Wikimedia Commons dataset downloader")
    print(f"Target: {PER_CLASS} images per class")
    print(f"Destination: {ROOT}")
    print(
        "Source: Wikimedia Commons only. Attribution and license details "
        "are recorded in each class's sources.csv."
    )

    totals: dict[str, int] = {}
    for class_name, categories in CATEGORIES.items():
        try:
            totals[class_name] = download_class(class_name, categories)
        except Exception as error:
            print(f"\n[{class_name}] failed; continuing to next class: {error}")
            totals[class_name] = len(_existing_images(ROOT / class_name))

    print("\nDone.")
    print("Image counts:")
    for class_name, count in totals.items():
        print(f"  {class_name}: {count}/{PER_CLASS}")


if __name__ == "__main__":
    main()
