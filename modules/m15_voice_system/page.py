import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import streamlit as st
from modules.m15_voice_system.service import execute_command

def render_page():
    st.header("M15 - Voice-Assisted Clinical Query System")
    st.caption("Type a natural language command — the system converts it to SQL")

    # example commands for demo
    st.markdown("**Try:** `show all patients` · `patients above 40` · `show visits` · `count visits`")

    command = st.text_input("Enter command")

    if st.button("Run Query"):
        if not command.strip():
            st.warning("Please enter a command")
            return

        results = execute_command(command)

        if not results:
            st.info("No results found")
            return

        # check if procedure returned an error
        if "error" in results[0]:
            st.error(results[0]["error"])
            return

        st.success(f"{len(results)} record(s) found")
        st.dataframe(results)
