# Module M15 - Voice-Assisted Clinical Query System

**Live Demo:** 👉 https://frontend-26cj.onrender.com

## 📌 Overview
Developed for IIT(ISM) Dhanbad (2025-26), this project is a Template-Based Natural Language to SQL Engine. It converts natural language text commands into structured SQL to output accurate clinical data, using pure database management concepts (stored procedures, templates, triggers, views) without relying on machine learning.

The system bypasses the dependency on technical staff, allowing doctors to access real-time clinical data instantly.

## 👥 Team & Acknowledgements
* **John Gunji** (24JE0621)
* **Lokesh Kommaraju** (24JE0637)
* **Manav Bharadwaj** (24JE0649)
* **Teaching Assistant:** Anshumala Rakesh

## 🛠️ Technology Stack
* **Frontend:** Streamlit
* **Backend Transport Layer:** Python and pymysql
* **Database (Production):** MySQL hosted on Railway.app

## ⚙️ System Architecture & Database Design
The system follows a strict isolation rule: Python never writes SQL; all query generation logic lives inside the MySQL stored procedure. Python serves only as the transport layer.

**Database Schema (10 Tables):** Built with 3NF normalization, FK CASCADE rules, ENUM constraints, and Composite indexes.
* **Core Entities:** Patient, Doctor, Visit (with FK relationships).
* **Records:** Prescription, Billing (Medical and financial records).
* **System Logic:** SQL_Action (stores 7 SQL query templates), CommandTemplate (keyword mapping).
* **Audit & Tracking:** VoiceCommand (logs every command), Context (extracted parameters), ExecutionLog (full audit trail of executed SQL).

**The Core Brain: ExecuteCommand Procedure:**
* Normalizes input using LOWER and TRIM.
* Scores all 7 templates based on keyword matches.
* Resolves ties deterministically using ORDER BY score DESC, template_id ASC.
* Extracts numerical parameters using REGEXP_SUBSTR.
* Dynamically builds conditions, replaces placeholders, prepares, executes, and logs the query.

**Triggers (3 Total):**
* `before_insert_voicecommand`: Ensures commands are lowercase and always start with a PENDING status.
* `after_insert_voicecommand`: Auto-initializes patient context when a command is received.
* `before_update_voicecommand`: Enforces execution status validity at the DB layer using SQLSTATE limits.

## 🧠 Key Technical Solutions
* **API Routing:** Implemented flask-cors to resolve browser CORS policy blocks between Render and Streamlit.
* **Backend Execution:** Utilized the stored_results iterator rather than fetchall to properly read the stored procedure output in pymysql.
* **Word Boundaries:** Used space-prefixes to prevent gender filter collisions.
* **State Management:** Eliminated stale context fallback to ensure each query remains fully self-contained without polluting subsequent SQL executions.
