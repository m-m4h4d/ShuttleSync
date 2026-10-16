import os
import ssl
from contextlib import contextmanager

import pymysql
from dotenv import load_dotenv

load_dotenv()


def _ssl_context():
    """TLS settings for hosted MySQL (Aiven, TiDB, ...).

    DB_SSL_CA holds the provider's CA certificate (the PEM text itself, so it
    can live in a Vercel environment variable). DB_SSL=true uses the system
    CA store instead.
    """
    ca = os.getenv("DB_SSL_CA")
    if ca:
        return ssl.create_default_context(cadata=ca.replace("\\n", "\n"))
    if os.getenv("DB_SSL", "").lower() in ("1", "true", "yes", "required"):
        return ssl.create_default_context()
    return None


@contextmanager
def get_connection():
    # A short-lived connection per request suits serverless hosting, where
    # pooled connections would outlive the function instance.
    connection = pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "ShuttleSync"),
        ssl=_ssl_context(),
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=10,
    )
    try:
        yield connection
    finally:
        connection.close()
