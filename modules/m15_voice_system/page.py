import sys
import os
import streamlit as st

# Ensure the app can find the service module and import functions
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))
from modules.m15_voice_system.service import execute_command, get_latest_query, get_command_history

def render_page():
    st.header("M15 - Clinical Query Copilot (Text Simulation)")
    st.caption("Type a natural language command — the system translates it to SQL")

    # Example commands for demo
    st.markdown("**Try:** `show all patients` · `show lab trends for patient 1` · `count visits`")
    
    # Initialize session state for the command
    if 'current_command' not in st.session_state:
        st.session_state.current_command = ""

    # UI Layout: Clean Text Input
    command_input = st.text_input("Enter clinical command:", value=st.session_state.current_command)
    if command_input != st.session_state.current_command:
        st.session_state.current_command = command_input

    # Run Button
    if st.button("Run Query"):
        if not st.session_state.current_command.strip():
            st.warning("Please enter a command.")
            return

        results = execute_command(st.session_state.current_command)

        if not results:
            st.info("No results found.")
        elif "error" in results[0]:
            st.error(results[0]["error"])
        else:
            st.success(f"{len(results)} record(s) found")
            
            # --- SHOW THE GENERATED SQL ---
            latest_sql = get_latest_query()
            if latest_sql:
                st.caption("Generated SQL Executed:")
                st.code(latest_sql, language="sql")
            
            # Render the data table
            st.dataframe(results)

    # --- SHOW COMMAND HISTORY ---
    st.divider()
    st.subheader("🕒 System Command History")
    st.caption("Audit log of recent natural language translations and execution status.")
    
    history_data = get_command_history()
    if history_data:
        st.dataframe(history_data, use_container_width=True, hide_index=True)
    else:
        st.info("No command history found yet.")
