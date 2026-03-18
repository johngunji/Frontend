import streamlit as st
import pymysql


def run_voice_system():
    st.title("M15 - Voice-Assisted Clinical Query System")

    command = st.text_input("Enter command")

    if st.button("Run Query"):
        if not command.strip():
            st.warning("Please enter a command")
            return

        try:
            conn = pymysql.connect(
                host="localhost",
                user="appuser",
                password="app123",
                database="m15",
                cursorclass=pymysql.cursors.DictCursor
            )
            cursor = conn.cursor()

            cursor.execute(
                "INSERT INTO VoiceCommand (command_text) VALUES (%s)",
                (command,)
            )
            conn.commit()

            command_id = cursor.lastrowid

            cursor.callproc("ExecuteCommand", [command_id])
            conn.commit()

            cursor.execute("""
                SELECT executed_query
                FROM ExecutionLog
                WHERE command_id = %s
                ORDER BY log_id DESC
                LIMIT 1
            """, (command_id,))

            log = cursor.fetchone()

            if not log:
                st.error("No query executed. Check template mapping or stored procedure.")
                cursor.close()
                conn.close()
                return

            executed_sql = log["executed_query"]

            st.subheader("Executed SQL")
            st.code(executed_sql, language="sql")

            if executed_sql.strip().lower().startswith("select"):
                cursor.execute(executed_sql)
                rows = cursor.fetchall()

                st.subheader("Result")

                if rows:
                    st.dataframe(rows)
                else:
                    st.info("No records found")
            else:
                st.success("Query executed successfully")

            cursor.close()
            conn.close()

        except pymysql.MySQLError as db_err:
            st.error(f"Database Error: {str(db_err)}")

        except Exception as e:
            st.error(f"Unexpected Error: {str(e)}")
