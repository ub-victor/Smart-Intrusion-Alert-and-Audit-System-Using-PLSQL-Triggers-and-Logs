# Smart Intrusion Alert & Audit System
## PL/SQL Final Project

**Student:** Ushindi Bihame Victoire  
**Lecturer:** Mr. Eric Maniraguha  
**Course:** Database Programming With PL/SQL  
**Institution:** AUCA  
**Academic Year:** 2025  

---

## Presentation Objectives
- Introduce the implemented system  
- Demonstrate security enforcement  
- Show working PL/SQL features  
- Present test results and audit logs  

**Speaking Notes:**  
This presentation showcases my PL/SQL project called **“Smart Intrusion Alert & Audit System.”** The project focuses on detecting unauthorized data modifications and auditing sensitive transactions at the database level.

---

# SLIDE 2 — System Overview

## What the System Does
- Detects unauthorized database access  
- Logs every **INSERT, UPDATE, DELETE**  
- Evaluates business security rules before execution  
- Generates alerts on suspicious transactions  

## Core Implementation Features
- PL/SQL packages  
- Database triggers  
- Application context (client IP detection)  
- Secure audit logging tables  

**Speaking Notes:**  
The system protects sensitive records by validating each modification attempt based on role, time, and action type.

---

# SLIDE 3 — Key Objectives

## Main Goals Achieved
- Prevent unauthorized modifications  
- Track usage of sensitive data  
- Notify administrators of suspicious events  
- Build evidence‑based audit logs  
- Generate analytics from logs  

## Why This Matters
- Organizations require strong internal controls  
- Ensures compliance with data-access policies  
- Supports accountability and transparency  

**Speaking Notes:**  
The aim is not only prevention but also creating a traceable history of user activity.

---

# SLIDE 4 — Project Architecture

## Architecture Layers  
**USER → PL/SQL Logic → Data Validation → Audit Trail**

## Components
- Security package: `security_pkg`  
- Trigger: `trg_secure_data_audit`  
- Application context: `CLIENT_IP`  
- Structured audit tables  

## Process Flow
1. User executes DML  
2. Trigger captures action  
3. `security_pkg.check_business_rules()` evaluates attempt  
4. Action allowed or blocked  
5. Audit logged  

**Speaking Notes:**  
All security enforcement happens inside the database engine.

---

# SLIDE 5 — ERD Explanation

## Entities
- **USERS** – system users  
- **SECURE_DATA** – sensitive records  
- **AUDIT_LOG** – event header  
- **AUDIT_DETAILS** – changed fields  
- **HOLIDAYS** – restricted dates  

## Relationships
- A user owns many secure data records (**1‑N**)  
- One audit_log event contains many audit_details (**1‑N**)  
- HOLIDAYS table enforces date restrictions  

**Speaking Notes:**  
This layout ensures normalization and structured auditing.

---

# SLIDE 6 — Business Rules Implemented

## System Logic
✔ Employees cannot modify data:  
- During weekdays (Mon–Fri)  
- During public holidays  

✔ DELETE restriction:  
- Only **ADMIN & AUDITOR** roles allowed  

✔ Full auditing for:  
- Authorized actions  
- Unauthorized attempts  

## Examples
- 🚫 Employee deleting on weekday → **Blocked**  
- ⚠ Unauthorized delete → **Alert + Log**  
- ✔ Auditor inserting → **Allowed**  

**Speaking Notes:**  
These reflect realistic enterprise controls.

---

# SLIDE 7 — Security Package

## Functions & Procedures
- `log_audit()` – inserts audit record  
- `send_alert()` – logs suspicious actions  
- `is_weekday(date)`  
- `is_public_holiday(date)`  
- `check_business_rules(...)` – **main validation engine**  

**Speaking Notes:**  
Centralizing rules avoids duplication and improves maintainability.

---

# SLIDE 8 — Trigger Functionality

## Trigger: `trg_secure_data_audit`
- Event: **BEFORE INSERT / UPDATE / DELETE**  
- Scope: statement + row level  

### Responsibilities
- Detect operation type  
- Identify user and role  
- Validate via package  
- Log all events  

**Speaking Notes:**  
No modification can bypass this trigger.

---

# SLIDE 9 — System Demonstration & Test Results

## Test Scenarios
- Employee UPDATE on weekday  
  → **Blocked**, error shown, logged  
- Unauthorized DELETE  
  → **Alert**, logged as *SUSPICIOUS*  
- Admin INSERT  
  → **Allowed**, logged as *NORMAL*  

## Evidence
- DBMS_OUTPUT alerts  
- audit_log entries  
- timestamps  
- captured IP  

---

# SLIDE 10 — Analytics & Insights

## Reports Generated
- Users with most violations  
- Suspicious activities per date  
- Time-based patterns  
- Blocked attempts  
- Authorized vs unauthorized frequency  

## Possible Visualizations
- Pie chart — violation types  
- Histogram — events per day  
- Ranking — users by attempts  

---

# SLIDE 11 — Challenges Faced

## Key Issues
- Trigger cannot commit  
- Context values expire  
- RI must stay intact  
- Need for atomic package logic  

## Solutions
✔ Moved commit logic outside triggers  
✔ Used `RAISE_APPLICATION_ERROR`  
✔ Rebuilt context handler  
✔ Added indexes  

---

# SLIDE 12 — Final Conclusion

## Final Achievements
- Fully automated auditing  
- Real DB‑level security  
- Validated test scenarios  
- Clean design & architecture  

## Future Enhancements
- Email notifications  
- Dashboard UI  
- User session tracking  
- Risk scoring engine  

**Speaking Notes:**  
The system meets requirements and is ready for further expansion.