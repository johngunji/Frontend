import streamlit as st
from modules.c3_voice_system import run_voice_system

def render_page():
    st.header("M15 - Voice-Assisted Clinical Query System")
    run_voice_system()
