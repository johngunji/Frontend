from modules.m15_voice_system.db import get_connection

def execute_command(command):
    conn = get_connection()
    try:
	cursor.callproc("ExecuteCommand", [command])
	rows = []
	for result in cursor.stored_results():
    	rows = result.fetchall()
	conn.commit()
	return rows
    except Exception as e:
        return [{"error": str(e)}]
    finally:
        conn.close()
# Add this to the bottom of service.py

def get_latest_query():
    """Fetches the exact SQL query that was just executed."""
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT executed_query FROM ExecutionLog ORDER BY executed_at DESC LIMIT 1")
        row = cursor.fetchone()
        return row['executed_query'] if row else None
    except Exception as e:
        return None
    finally:
        conn.close()

def get_command_history():
    """Fetches the last 10 commands from the CommandHistory view."""
    conn = get_connection()
    try:
        cursor = conn.cursor()
        # Pulling from the view we created in views.sql
        cursor.execute("""
            SELECT 
                command_text AS 'Natural Language Command', 
                response_text AS 'Generated SQL / Response', 
                execution_status AS 'Status', 
                issued_time AS 'Timestamp' 
            FROM CommandHistory 
            ORDER BY issued_time DESC 
            LIMIT 10
        """)
        return cursor.fetchall()
    except Exception as e:
        return []
    finally:
        conn.close()
