# Training the craft image classifier

## 1. Add labeled images

Put each image directly in the folder matching its class:

```text
backend/
  dataset/
    basket/
    pot/
    saree/
    toy/
    cloth/
```

Supported formats are JPG, JPEG, PNG, BMP, and WebP. The script uses a
deterministic, per-class 80/20 training/validation split.

For an initial prototype, aim for **100-200 varied images per category**.
Fifty per category can test the pipeline, but results may be unreliable.
Include different examples, views, backgrounds, and lighting. Avoid
near-duplicate photos, especially across the automatic training and validation
split.

## 2. Install training-only packages

From PowerShell, run:

```powershell
cd C:\Projects\KalaSaathi\backend
.\venv\Scripts\python.exe -m pip install -r requirements-training.txt
```

This installs CPU PyTorch, TorchVision, ONNX, and Pillow. Pillow is already a
backend dependency; it is listed here too so the training requirements file is
self-contained. The first training run downloads TorchVision's pretrained
MobileNetV3-Small weights (about 10 MB); it does not download a dataset.

## 3. Train and export

From the same `backend` directory:

```powershell
.\venv\Scripts\python.exe train_craft_classifier.py --batch-size 8
```

The script trains on CPU from pretrained MobileNetV3-Small weights, keeps most
of the feature extractor frozen, fine-tunes its last two feature blocks, keeps
the pretrained classifier projection frozen, and trains the five-class output
layer. Training uses random resized crops, horizontal flips, small rotations,
and mild color variation; validation images receive only resize and
normalization. The split is seeded (default 42).
Only about 23% of model parameters are trainable; most remain frozen. If the
training split is imbalanced, the script uses class-balanced sampling.
Early stopping watches validation loss and accuracy (default patience: 7),
with a maximum of 40 epochs (or the lower `--epochs` value supplied). It
selects the best checkpoint by validation accuracy, using validation loss to
break ties, and exports:

- `models/kala_craft_classifier_v2.onnx`
- `models/kala_craft_classes_v2.txt` (class order: basket, pot, saree, toy, cloth)
- `training-output/craft_classifier_v2_best.pth`

These defaults preserve the first training run's checkpoint and ONNX model.

The ONNX export has five output scores in the order in the labels file. The
current `app/ai_classifier.py` still requires 1,000 ImageNet labels and maps
ImageNet label keywords; it will need a separate update to consume this new
five-class model. This setup intentionally does not change that application
code or the API route.
