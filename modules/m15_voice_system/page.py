import sys
import os
import streamlit as st

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))
from modules.m15_voice_system.service import execute_command, get_latest_query, get_command_history, get_stats, get_matched_template

def render_page():
    st.header("🧠 M15 - Voice-Assisted Clinical Query System")
    st.caption("Type a natural language command — the DBMS engine translates it to SQL")

    # --- QUICK CLICK BUTTONS ---
    st.markdown("**Quick Commands:**")
    cols = st.columns(4)
    quick_commands = [
        "show all patients",
        "show diabetic patients",
        "show pending bills",
        "count all patients",
        "show elderly patients",
        "show diagnosis frequency",
        "show medicine frequency",
        "show doctor workload",
    ]
    for i, cmd in enumerate(quick_commands):
        if cols[i % 4].button(cmd, key=f"quick_{i}"):
            st.session_state.current_command = cmd

    st.divider()

    # --- STATS PANEL ---
    stats = get_stats()
    if stats:
        c1, c2, c3 = st.columns(3)
        c1.metric("Total Commands", stats.get("total", 0))
        c2.metric("Successful", stats.get("done", 0))
        c3.metric("Failed", stats.get("failed", 0))

    st.divider()

    # --- COMMAND INPUT ---
    if 'current_command' not in st.session_state:
        st.session_state.current_command = ""

    command_input = st.text_input("Enter clinical command:", value=st.session_state.current_command)
    if command_input != st.session_state.current_command:
        st.session_state.current_command = command_input

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

            # --- MATCHED TEMPLATE ---
            matched = get_matched_template()
            if matched:
                st.caption(f"Matched Template: `{matched}`")

            # --- GENERATED SQL ---
            latest_sql = get_latest_query()
            if latest_sql:
                st.caption("Generated SQL Executed:")
                st.code(latest_sql, language="sql")

            st.dataframe(results)

            # --- CSV EXPORT ---
            import pandas as pd
            df = pd.DataFrame(results)
            csv = df.to_csv(index=False).encode('utf-8')
            st.download_button(
                label="Download Results as CSV",
                data=csv,
                file_name="m15_query_results.csv",
                mime="text/csv"
            )
    # --- COMMAND HISTORY ---
    st.divider()
    st.subheader("🕒 System Command History")
    st.caption("Audit log of recent natural language translations and execution status.")

    history_data = get_command_history()
    if history_data:
        st.dataframe(history_data, use_container_width=True, hide_index=True)
    else:
        st.info("No command history found yet.")