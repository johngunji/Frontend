import streamlit as st

def render_page():
    st.title("M15 - Voice-Assisted Clinical Query System")

    query = st.text_input("Enter command")

    if st.button("Run Query"):
        st.write("Query received:", query)
