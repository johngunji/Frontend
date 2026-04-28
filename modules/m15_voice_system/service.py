from db import get_connection

def execute_command(command):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("CALL ExecuteCommand(%s)", [command])
        rows = cursor.fetchall()
        conn.commit()
        return rows
    except Exception as e:
        return [{"error": str(e)}]
    finally:
        conn.close()


def get_latest_query():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT executed_query 
            FROM ExecutionLog 
            ORDER BY executed_at DESC 
            LIMIT 1
        """)
        row = cursor.fetchone()
        return row['executed_query'] if row else None
    finally:
        conn.close()


def get_command_history():
    conn = get_connection()
    try:
        cursor = conn.cursor()
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
    finally:
        conn.close()


def get_stats():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                COUNT(*) AS total,
                SUM(execution_status = 'DONE') AS done,
                SUM(execution_status = 'FAILED') AS failed
            FROM VoiceCommand
        """)
        return cursor.fetchone()
    finally:
        conn.close()


def get_matched_template():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ct.template_pattern
            FROM VoiceCommand vc
            JOIN CommandTemplate ct 
                ON vc.template_id = ct.template_id
            ORDER BY vc.issued_time DESC
            LIMIT 1
        """)
        row = cursor.fetchone()
        return row['template_pattern'] if row else None
    finally:
        conn.close()


def get_template_usage():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ct.template_pattern, COUNT(*) AS usage_count
            FROM VoiceCommand vc
            JOIN CommandTemplate ct 
                ON vc.template_id = ct.template_id
            GROUP BY ct.template_pattern
            ORDER BY usage_count DESC
            LIMIT 8
        """)
        return cursor.fetchall()
    finally:
        conn.close()
