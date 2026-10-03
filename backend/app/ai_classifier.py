import io
import os
from functools import lru_cache
from pathlib import Path

import numpy as np
import onnxruntime as ort
from PIL import Image, UnidentifiedImageError

_MODEL_PATH = Path(
    os.getenv(
        "KALASAATHI_CLASSIFIER_MODEL",
        Path(__file__).resolve().parents[1]
        / "models"
        / "kala_craft_classifier_v2.onnx",
    )
)
_LABELS_PATH = Path(
    os.getenv(
        "KALASAATHI_CLASSIFIER_LABELS",
        Path(__file__).resolve().parents[1]
        / "models"
        / "kala_craft_classes_v2.txt",
    )
)
_PRODUCT_NAMES = {
    "basket": "Traditional Handwoven Bamboo Basket",
    "pot": "Handcrafted Terracotta Folk Art Vase",
    "saree": "Authentic Pochampally Ikat Silk Saree",
    "toy": "Handcrafted Channapatna Lacquer Wooden Toy",
    "cloth": "Handwoven Ethnic Cotton Fabric",
    "default": "Traditional Handcrafted Artisan Product",
}
_LOW_CONFIDENCE_THRESHOLD = 0.20


@lru_cache(maxsize=1)
def _get_session() -> ort.InferenceSession:
    if not _MODEL_PATH.is_file() or not _LABELS_PATH.is_file():
        raise RuntimeError(
            "Local image classifier is unavailable. Check the model and labels files."
        )
    try:
        return ort.InferenceSession(
            str(_MODEL_PATH), providers=["CPUExecutionProvider"]
        )
    except Exception as error:
        raise RuntimeError("Local image classifier could not be loaded") from error


@lru_cache(maxsize=1)
def _get_labels() -> tuple[str, ...]:
    try:
        labels = tuple(
            line.strip().lower()
            for line in _LABELS_PATH.read_text(encoding="utf-8").splitlines()
            if line.strip()
        )
    except OSError as error:
        raise RuntimeError("Local image classifier labels are unavailable") from error
    if len(labels) != 5 or len(set(labels)) != 5:
        raise RuntimeError("Expected five unique craft class labels")
    return labels


def _preprocess(image_bytes: bytes) -> np.ndarray:
    try:
        with Image.open(io.BytesIO(image_bytes)) as image:
            image = image.convert("RGB").resize((224, 224), Image.Resampling.BILINEAR)
            pixels = np.asarray(image, dtype=np.float32) / 255.0
    except (UnidentifiedImageError, OSError) as error:
        raise ValueError("The uploaded file is not a readable image") from error

    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    normalized = (pixels - mean) / std
    return np.expand_dims(normalized.transpose(2, 0, 1), axis=0)


def classify_image(image_bytes: bytes) -> dict[str, str | float]:
    session = _get_session()
    labels = _get_labels()
    input_tensor = _preprocess(image_bytes)
    output = session.run(None, {session.get_inputs()[0].name: input_tensor})[0]
    scores = np.asarray(output).reshape(-1).astype(np.float64)
    if scores.size != len(labels):
        raise RuntimeError("Classifier returned an unexpected number of classes")

    shifted = scores - scores.max()
    exponentials = np.exp(shifted)
    probabilities = exponentials / exponentials.sum()
    best_index = int(np.argmax(probabilities))
    predicted_key = labels[best_index]
    confidence = float(probabilities[best_index])
    product_key = predicted_key
    if (
        product_key not in _PRODUCT_NAMES
        or product_key == "default"
        or confidence < _LOW_CONFIDENCE_THRESHOLD
    ):
        product_key = "default"
        confidence = 0.0

    return {
        "product_key": product_key,
        "product_name": _PRODUCT_NAMES[product_key],
        "confidence": round(confidence, 4),
    }