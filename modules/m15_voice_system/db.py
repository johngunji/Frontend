
import pymysql

def get_connection():
    return pymysql.connect(
        host="localhost",
        user="appuser",
        password="app123",
        database="m15",
        cursorclass=pymysql.cursors.DictCursor
    )
