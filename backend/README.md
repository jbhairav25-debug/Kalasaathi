# KalaSaathi Backend

FastAPI backend foundation for the existing KalaSaathi Flutter project.

## Setup

From this directory:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Configure the MySQL connection values in `.env`:

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=kalasaathi
```

The backend does not connect to MySQL during startup, so `/health` remains
available while the database is unavailable. It creates missing tables from the
SQLAlchemy models the first time a database-backed endpoint is used. On Railway,
configure `MYSQL_URL` or all five `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`,
`MYSQLPASSWORD`, and `MYSQLDATABASE` variables. Local `.env`/`DB_*` settings
remain supported for development.

## Local image classification

The `POST /ai/classify` endpoint uses a local MobileNetV2 ONNX model (CPU inference) and ImageNet labels stored in `models/`. The model is about 14 MB. Its ImageNet labels are conservatively mapped to the existing KalaSaathi product keys; uncertain or unrelated images return `default`. No Ollama vision model is required.

The multipart field is named `file`. Flutter Web uses `http://127.0.0.1:8000` by default and the Android emulator uses `http://10.0.2.2:8000`. For a physical Android device, set the PC's LAN URL at Flutter launch:

```powershell
flutter run --dart-define=KALASAATHI_API_BASE_URL=http://192.168.1.10:8000
```

Replace the sample LAN address with the development PC's address. The backend must be reachable on port 8000 from the device.

## Run

```powershell
uvicorn app.main:app --reload
```

Available endpoints:

- `GET /` - API welcome response
- `GET /health` - health status
- `/docs` - Swagger UI
