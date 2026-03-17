# dashboards/doctor_dashboard.py
import streamlit as st
from components.sidebar import sidebar
from components.charts import patient_line_chart, appointment_donut_chart
import matplotlib.pyplot as plt

# ✅ NEW IMPORT (IMPORTANT)
from modules.c3_voice_system import run_voice_system

# All categories and their modules
CATEGORIES = {
    "A - Patient Clinical Data": {
        "title": "Patient Clinical Data Management",
        "description": "Patient records, medical history, diagnoses, and treatment plans",
        "icon": "🏥",
        "stats": {"modules": "6", "records": "45,230", "alerts": "12"},
        "modules": [
            ("A1", "Patient Demographics & Visit History", "Patient demographics and admission data", 5, 12500),
            ("A2", "Chronic Disease Patient Record", "Past medical records and conditions", 4, 8900),
            ("A3", "Pediatric Patient Clinical Data", "ICD codes and diagnosis tracking", 3, 15600),
            ("A4", "Geriatric Patient Health Record", "Care plans and treatment", 6, 7800),
            ("A5", "Patient Allergy & Immunization", "Patient vitals and monitoring", 4, 9200),
            ("A6", "Clinical Alert System", "Doctor notes and observations", 5, 11400)
        ]
    },
    "B - Laboratory Management": {
        "title": "Laboratory Management",
        "description": "Lab tests, results, equipment, and sample tracking",
        "icon": "🧪",
        "stats": {"modules": "5", "records": "12,840", "alerts": "5"},
        "modules": [
            ("B1", "Laboratory Test Management", "Test ordering system", 9, 22300),
            ("B2", "Automated Lab Result Interpretation", "AI result analysis", 6, 15800),
            ("B3", "Reference Range Validation", "Normal range database", 4, 12400),
            ("B4", "Follow-Up Test Recommendation", "Test suggestion system", 5, 9100),
            ("B5", "Pathology Report Management", "Pathology database", 7, 11200)
        ]
    },
    "C - Pharmacy & Medications": {
        "title": "Pharmacy & Medications",
        "description": "Drug inventory, prescriptions, and dispensing records",
        "icon": "💊",
        "stats": {"modules": "6", "records": "28,450", "alerts": "3"},
        "modules": [
            ("C1", "Drug-Drug Interaction Alert", "Interaction database", 7, 18500),
            ("C2", "Prescription Validation System", "Consistency checks", 5, 12300),
            ("C3", "Voice-Assisted Clinical Query System", "Text-based voice simulation system", 4, 9800),
            ("C4", "Polypharmacy Risk Detection", "Multiple drug analysis", 6, 11200),
            ("C5", "High-Risk Drug Monitoring", "Critical medication tracking", 5, 8700),
            ("C6", "Automated Prescription Audit", "Prescription review system", 4, 7300)
        ]
    },

    # (Remaining categories unchanged)
    "D - Hospital Operations": {
        "title": "Hospital Operations",
        "description": "Bed management, admissions, and facility operations",
        "icon": "🏥",
        "stats": {"modules": "6", "records": "34,120", "alerts": "8"},
        "modules": [
            ("D1", "Bed Management System", "Bed allocation and tracking", 5, 8900),
            ("D2", "Patient Admission & Discharge", "Admission workflows", 7, 12400),
            ("D3", "Operating Room Scheduling", "OR booking system", 6, 5600),
            ("D4", "Emergency Department Triage", "ED patient management", 8, 4200),
            ("D5", "Ward Management System", "Ward operations", 5, 2100),
            ("D6", "Hospital Facility Management", "Facility tracking", 4, 920)
        ]
    },
    "E - Billing & Insurance": {
        "title": "Billing & Insurance",
        "description": "Patient billing, insurance claims, and payment processing",
        "icon": "💳",
        "stats": {"modules": "5", "records": "18,760", "alerts": "6"},
        "modules": [
            ("E1", "Patient Billing System", "Invoice generation", 8, 15600),
            ("E2", "Insurance Claims Management", "Claims processing", 6, 12300),
            ("E3", "Payment Processing", "Payment tracking", 5, 9800),
            ("E4", "Revenue Cycle Management", "Financial analytics", 7, 8900),
            ("E5", "Pricing & Tariff Management", "Price management", 4, 4160)
        ]
    }
}

# ---------------- MAIN ROUTER ----------------

def doctor_dashboard():
    st.session_state.setdefault("view", "main")
    st.session_state.setdefault("selected_category", None)
    st.session_state.setdefault("selected_module", None)

    sidebar([
        "Dashboard",
        "A - Patient Clinical Data",
        "B - Laboratory Management",
        "C - Pharmacy & Medications"
    ])

    if st.session_state.view == "category":
        show_category_view()
    elif st.session_state.view == "module":
        show_module_detail()
    else:
        show_main_dashboard()

# ---------------- MAIN DASHBOARD ----------------

def show_main_dashboard():
    st.markdown("### Welcome back! Here's your hospital overview.")
    st.divider()

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("👥 Total Patients", "12,450")
    c2.metric("⚠️ Active Alerts", "320")
    c3.metric("📋 Lab Reports", "185")
    c4.metric("💊 Prescriptions", "750")

    st.divider()
    st.markdown("## System Categories")

    for idx, (key, cat) in enumerate(CATEGORIES.items()):
        if st.button(f"{cat['icon']} {key}", key=f"cat_{idx}"):
            st.session_state.selected_category = key
            st.session_state.view = "category"
            st.rerun()

# ---------------- CATEGORY VIEW ----------------

def show_category_view():
    cat_key = st.session_state.selected_category
    category = CATEGORIES[cat_key]

    st.markdown(f"# {category['icon']} {category['title']}")
    st.markdown(category['description'])
    st.divider()

    for module in category["modules"]:
        code, name, desc, _, _ = module

        if st.button(f"{code} - {name}", key=code):
            st.session_state.selected_module = module
            st.session_state.view = "module"
            st.rerun()

    if st.button("⬅ Back"):
        st.session_state.view = "main"
        st.rerun()

# ---------------- MODULE VIEW ----------------

def show_module_detail():
    code, name, desc, tables, records = st.session_state.selected_module

    # ✅ C3 MODULE (FINAL INTEGRATION)
    if code == "C3":
        run_voice_system()

        if st.button("⬅ Back to Modules"):
            st.session_state.view = "category"
            st.rerun()

        return

    # Default modules
    st.title(name)
    st.write(desc)

    tab = st.radio("Tabs", ["Home", "SQL", "Output"])

    if tab == "Home":
        st.info("Module overview")

    elif tab == "SQL":
        st.code("SELECT * FROM patients;", language="sql")

    elif tab == "Output":
        st.success("Sample output shown here")

    if st.button("⬅ Back"):
        st.session_state.view = "category"
        st.rerun()
