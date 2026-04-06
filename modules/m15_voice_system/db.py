import pymysql
import os

def get_connection():
    return pymysql.connect(
        host=os.environ.get("DB_HOST", "ballast.proxy.rlwy.net"),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "railway"),
        port=int(os.environ.get("DB_PORT", 14747)),
        cursorclass=pymysql.cursors.DictCursor
    )
