
import streamlit as st
from modules.m15_voice_system.service import execute_command

def render_page():
    st.header("M15 - Voice-Assisted Clinical Query System")

    command = st.text_input("Enter command")

    if st.button("Run Query"):
        if not command.strip():
            st.warning("Please enter a command")
            return

        rows = execute_command(command)

        if rows:
            st.dataframe(rows)
        else:
            st.info("No results found")
