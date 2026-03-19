# dashboards/doctor_dashboard.py

import streamlit as st
from components.sidebar import sidebar
from components.charts import patient_line_chart, appointment_donut_chart
import matplotlib.pyplot as plt

# ✅ C3 MODULE IMPORT
from modules.m15_voice_system.page import render_page

# ---------------- CATEGORIES ----------------

CATEGORIES = {
    "A - Patient Clinical Data": {
        "title": "Patient Clinical Data Management",
        "description": "Patient records, medical history, diagnoses, and treatment plans",
        "icon": "🏥",
        "modules": [
            ("A1", "Patient Demographics & Visit History", "Patient demographics and admission data", 5, 12500),
            ("A2", "Chronic Disease Patient Record", "Past medical records and conditions", 4, 8900),
        ]
    },
    "B - Laboratory Management": {
        "title": "Laboratory Management",
        "description": "Lab tests, results, and tracking",
        "icon": "🧪",
        "modules": [
            ("B1", "Laboratory Test Management", "Test ordering system", 9, 22300),
        ]
    },
    "C - Pharmacy & Medications": {
        "title": "Pharmacy & Medications",
        "description": "Drug inventory and prescriptions",
        "icon": "💊",
        "modules": [
            ("C1", "Drug Interaction Alert", "Interaction database", 7, 18500),
            ("C2", "Prescription Validation", "Consistency checks", 5, 12300),
            ("C3", "Voice-Assisted Clinical Query System", "Text-based voice system", 4, 9800),
        ]
    }
}


# ---------------- MAIN ROUTER ----------------

def doctor_dashboard():
    st.session_state.setdefault("view", "main")
    st.session_state.setdefault("selected_category", None)
    st.session_state.setdefault("selected_module", None)

    # ✅ SIDEBAR FIXED
    selected = sidebar([
        "Dashboard",
        "A - Patient Clinical Data",
        "B - Laboratory Management",
        "C - Pharmacy & Medications"
    ])

    if selected == "Dashboard":
        st.session_state.view = "main"

    elif selected in CATEGORIES:
        st.session_state.selected_category = selected
        st.session_state.view = "category"

    # ROUTING
    if st.session_state.view == "category":
        show_category_view()
    elif st.session_state.view == "module":
        show_module_detail()
    else:
        show_main_dashboard()


# ---------------- MAIN DASHBOARD ----------------

def show_main_dashboard():
    st.title("🏥 Doctor Dashboard")

    c1, c2, c3 = st.columns(3)
    c1.metric("Patients", "12,450")
    c2.metric("Alerts", "320")
    c3.metric("Reports", "185")

    st.divider()

    st.subheader("Categories")

    for idx, (key, cat) in enumerate(CATEGORIES.items()):
        if st.button(f"{cat['icon']} {key}", key=f"cat_{idx}"):
            st.session_state.selected_category = key
            st.session_state.view = "category"
            st.rerun()


# ---------------- CATEGORY VIEW ----------------

def show_category_view():
    cat_key = st.session_state.selected_category

    if cat_key not in CATEGORIES:
        st.warning("Invalid category")
        return

    category = CATEGORIES[cat_key]

    st.title(f"{category['icon']} {category['title']}")
    st.caption(category['description'])

    st.divider()

    for module in category["modules"]:
        code, name, desc, _, _ = module

        if st.button(f"{code} - {name}", key=f"mod_{code}"):
            st.session_state.selected_module = module
            st.session_state.view = "module"
            st.rerun()

    if st.button("⬅ Back"):
        st.session_state.view = "main"
        st.rerun()


# ---------------- MODULE VIEW ----------------

def show_module_detail():

    # ✅ SAFETY CHECK
    if st.session_state.selected_module is None:
        st.warning("No module selected")
        return

    code, name, desc, tables, records = st.session_state.selected_module

    # ✅ C3 MODULE (VOICE SYSTEM)
    if code == "C3":
        st.header("🧠 Voice-Assisted Clinical Query System")
        st.caption("Simulate voice-based clinical queries using text")

        render_page()

        if st.button("⬅ Back to Modules"):
            st.session_state.view = "category"
            st.rerun()

        return

    # ---------------- DEFAULT MODULE ----------------

    st.title(name)
    st.caption(desc)

    tab = st.radio("Tabs", ["Home", "SQL", "Output"])

    if tab == "Home":
        st.info("Module overview")

    elif tab == "SQL":
        st.code("SELECT * FROM patients;", language="sql")

    elif tab == "Output":
        st.success("Sample output")

    if st.button("⬅ Back"):
        st.session_state.view = "category"
        st.rerun()
