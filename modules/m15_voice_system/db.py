import pymysql

def get_connection():
    return pymysql.connect(
        host="ballast.proxy.rlwy.net",
        user="root",
        password="kaKwheqjrLpnkHxbgCfZebXpPSMQyZPp",
        database="railway",
        port=14747,
        cursorclass=pymysql.cursors.DictCursor
    )
