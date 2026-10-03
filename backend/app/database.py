import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL, make_url
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv(Path(__file__).resolve().parents[1] / ".env", override=False)


def _database_url() -> URL:
    mysql_url = os.getenv("MYSQL_URL")
    if mysql_url:
        url = make_url(mysql_url)
        if url.drivername == "mysql":
            url = url.set(drivername="mysql+pymysql")
        return url

    return URL.create(
        drivername="mysql+pymysql",
        username=os.getenv("MYSQLUSER") or os.getenv("DB_USER", "root"),
        password=os.getenv("MYSQLPASSWORD") or os.getenv("DB_PASSWORD", ""),
        host=os.getenv("MYSQLHOST") or os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQLPORT") or os.getenv("DB_PORT", "3306")),
        database=os.getenv("MYSQLDATABASE") or os.getenv("DB_NAME", "kalasaathi"),
    )


DATABASE_URL = _database_url()

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()