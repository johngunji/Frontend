# modules/c3_voice_system.py

import streamlit as st
import re

# -----------------------------
# COMMAND TEMPLATES
# -----------------------------
COMMAND_TEMPLATES = [
    {
        "type": "retrieval",
        "keywords": ["patients", "above"],
        "sql": "SELECT name FROM patients WHERE age > {age}"
    },
    {
        "type": "retrieval",
        "keywords": ["diabetes"],
        "sql": "SELECT name FROM patients WHERE disease = 'diabetes'"
    },
    {
        "type": "calculation",
        "keywords": ["count", "patients"],
        "sql": "SELECT COUNT(*) FROM patients"
    }
]

# -----------------------------
# CONTEXT EXTRACTOR
# -----------------------------
def extract_context(command):
    context = {}

    # Extract age
    age_match = re.search(r'\b(\d{2})\b', command)
    if age_match:
        context["age"] = age_match.group(1)

    return context

# -----------------------------
# TEMPLATE MATCHER
# -----------------------------
def match_template(command):
    for template in COMMAND_TEMPLATES:
        if all(word in command for word in template["keywords"]):
            return template
    return None

# -----------------------------
# SQL GENERATOR
# -----------------------------
def generate_sql(template, context):
    sql = template["sql"]

    if "{age}" in sql:
        sql = sql.replace("{age}", context.get("age", "0"))

    return sql

# -----------------------------
# FAKE DATABASE EXECUTION
# -----------------------------
def execute_query(sql):
    if "age >" in sql:
        return ["Rahul Sharma", "John Doe", "Amit Patel"]
    elif "diabetes" in sql:
        return ["Patient A", "Patient B"]
    elif "COUNT" in sql:
        return ["12450"]
    else:
        return ["No results"]

# -----------------------------
# MAIN UI FUNCTION
# -----------------------------
def run_voice_system():
    st.title("Voice-Assisted Clinical Query System")

    # Command history
    if "history" not in st.session_state:
        st.session_state.history = []

    command = st.text_input("Enter command")

    if st.button("Run Query"):
        if command:
            cmd = command.lower()

            # Step 1: Context
            context = extract_context(cmd)

            # Step 2: Template
            template = match_template(cmd)

            if template:
                # Step 3: SQL generation
                sql = generate_sql(template, context)

                # Step 4: Execute
                result = execute_query(sql)

                # Save history
                st.session_state.history.append(command)

                st.markdown(f"**SQL:** {sql}")
                st.success(f"Result: {', '.join(result)}")

            else:
                st.error("❌ Could not understand command")

    # -----------------------------
    # COMMAND HISTORY
    # -----------------------------
    st.divider()
    st.subheader("Command History")

    for cmd in reversed(st.session_state.history[-5:]):
        st.write(f"🗣 {cmd}")
