
from modules.m15_voice_system.db import get_connection

def execute_command(command):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.callproc("ExecuteCommand", [command])
        rows = cursor.fetchall()
        return rows
    finally:
        conn.close()
