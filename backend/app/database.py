import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv
from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.engine import URL, make_url
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv(Path(__file__).resolve().parents[1] / ".env", override=False)


def _is_railway() -> bool:
    return any(
        os.getenv(name)
        for name in (
            "RAILWAY_ENVIRONMENT",
            "RAILWAY_ENVIRONMENT_NAME",
            "RAILWAY_PROJECT_ID",
            "RAILWAY_SERVICE_ID",
            "RAILWAY_DEPLOYMENT_ID",
        )
    )


def _database_url() -> URL | None:
    mysql_url = os.getenv("MYSQL_URL")
    if mysql_url:
        url = make_url(mysql_url)
        if url.drivername == "mysql":
            url = url.set(drivername="mysql+pymysql")
        return url

    railway_variables = (
        os.getenv("MYSQLHOST"),
        os.getenv("MYSQLPORT"),
        os.getenv("MYSQLUSER"),
        os.getenv("MYSQLPASSWORD"),
        os.getenv("MYSQLDATABASE"),
    )
    if all(value is not None for value in railway_variables):
        host, port, username, password, database = railway_variables
        return URL.create(
            drivername="mysql+pymysql",
            username=username,
            password=password,
            host=host,
            port=int(port),
            database=database,
        )

    if _is_railway():
        return None

    return URL.create(
        drivername="mysql+pymysql",
        username=os.getenv("MYSQLUSER") or os.getenv("DB_USER", "root"),
        password=os.getenv("MYSQLPASSWORD") or os.getenv("DB_PASSWORD", ""),
        host=os.getenv("MYSQLHOST") or os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQLPORT") or os.getenv("DB_PORT", "3306")),
        database=os.getenv("MYSQLDATABASE") or os.getenv("DB_NAME", "kalasaathi"),
    )


DATABASE_URL = _database_url()
Base = declarative_base()
engine = (
    create_engine(DATABASE_URL, pool_pre_ping=True)
    if DATABASE_URL is not None
    else None
)
SessionLocal = (
    sessionmaker(autocommit=False, autoflush=False, bind=engine)
    if engine is not None
    else None
)


@lru_cache(maxsize=1)
def _ensure_tables() -> None:
    if engine is None:
        raise HTTPException(
            status_code=503,
            detail="Database configuration is missing",
        )
    Base.metadata.create_all(bind=engine)


def get_db():
    _ensure_tables()
    if SessionLocal is None:
        raise HTTPException(
            status_code=503,
            detail="Database configuration is missing",
        )
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()