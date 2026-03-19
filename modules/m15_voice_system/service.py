from modules.m15_voice_system.db import get_connection

def execute_command(command):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.callproc("ExecuteCommand", [command])
        rows = cursor.fetchall()
        conn.commit()
        return rows
    except Exception as e:
        return [{"error": str(e)}]
    finally:
        conn.close()