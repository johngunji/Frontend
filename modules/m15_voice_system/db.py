import pymysql
import os

def get_connection():
    try:
        return pymysql.connect(
            host=os.environ["DB_HOST"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
            database=os.environ["DB_NAME"],
            port=int(os.environ["DB_PORT"]),
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )
    except KeyError as e:
        raise Exception(f"Missing environment variable: {e}")
    except Exception as e:
        raise Exception(f"Database connection failed: {str(e)}")
