import pymysql

def get_connection():
    return pymysql.connect(
        host="localhost",
        user="root",          # use root for now (avoid appuser issues)
        password="root123",  # put your actual MySQL password
        database="m15",
        cursorclass=pymysql.cursors.DictCursor
    )