# Deploy the backend to Railway

Create a Railway service from this repository with the service Root Directory set
to `/backend`. The `railway.toml` in that directory explicitly selects the
Dockerfile builder and `Dockerfile`; do not configure Railpack or override the
Docker build/start commands.

The image installs only `requirements.txt`, copies `app/` and `models/`, and
starts Uvicorn on `0.0.0.0:$PORT`. Railway provides `PORT`, so no custom Start
Command is required. Railway's `/health` check is independent of the database
and ONNX model.

Set these service variables:

- `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, and `MYSQLDATABASE`
  from the Railway MySQL service, or set `MYSQL_URL` to its connection URL.
  `MYSQL_URL` takes precedence when provided. Credentials are read from the
  environment and are not included in the image.
- `FRONTEND_ORIGIN` to the deployed Flutter Web origin (scheme and host, with
  no path). Multiple comma-separated origins are accepted. Local development
  origins are also allowed.

The `/ai/classify` endpoint continues to load the packaged ONNX model lazily
and runs inference with ONNX Runtime's CPU provider.
