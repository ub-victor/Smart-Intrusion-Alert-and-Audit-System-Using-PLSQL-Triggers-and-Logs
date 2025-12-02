# Smart Intrusion Alert & Audit System (PL/SQL Final Project)

**Student:** Ushindi Bihame Victoire  
**Student ID:** 27269  
**Course:** PL/SQL (INSY 8311)  
**Instructor:** Mr. Eric Maniraguha  
**Project:** Smart Intrusion Alert and Audit System Using PL/SQL Triggers and Logs  
**Completion Date:** December 7, 2025

## Project Overview
This project implements a database-level intrusion detection and auditing system using Oracle PL/SQL, triggers, and audit tables. The system:
- Monitors INSERT/UPDATE/DELETE on sensitive tables (`secure_data`).
- Enforces business rules (no DML by employees on weekdays or public holidays).
- Logs all attempts to `audit_log` (username, action, time, IP, status, details).
- Flags suspicious events and simulates alerts via DBMS_OUTPUT and audit entries.
- Provides analytic queries and dashboard-ready datasets for BI reporting.

## Contents
- `database/02_ddl_create_tables_and_population.sql` — DDL for tables, sequences, indexes, and population script.
- `database/05_packages_and_functions.sql` — `security_pkg` package with audit, check rules, alerting.
- `database/06_triggers_and_audit.sql` — compound trigger for `secure_data` and helper `set_client_ip`.
- `database/07_test_cases.sql` — test scripts showing denied/allowed actions and audit output.
- `database/08_analytics_queries.sql` — BI-oriented queries and window-function examples.
- `screenshots/` — store required screenshots (ER diagram, SQL Developer execution, audit log results, dashboards)
- `presentation/` — PowerPoint with 10 slides for demonstration of my work.
- `README.md` — this file.

## Quick start (run in this order)
1. Connect to Oracle as DBA (optional) to create user & tablespaces: `01_create_user_and_tablespaces.sql`.
2. Connect as project user (e.g., `ushindi`) and run:
   - `02_ddl_create_tables_and_population.sql`
   - `05_packages_and_functions.sql`
   - `06_triggers_and_audit.sql`
   - `07_test_cases.sql` (run tests)
   - `08_analytics_queries.sql` (generate KPI reports)
3. For demonstrations, set client IP per session:
   - `BEGIN set_client_ip('10.0.0.15'); END;`
4. Capture screenshots for submission:
   - ER diagram
   - SQL Developer showing triggers, audit entries
   - BI dashboard screenshots or query result screenshots

## How to run (tools)
- **Oracle SQL Developer** — recommended for editing and running scripts, screenshots.
- **SQLcl** or **SQL*Plus** — run scripts from terminal.
- **VS Code** — with Oracle Developer Tools extension or use SQLcl inside terminal.
- **Lucidchart / draw.io** — create BPMN and ER diagrams.
- **Metabase / Power BI / Tableau** — build dashboards for BI part.

## Testing & grading checklist
- [x] BPMN diagram + 1-page explanation
- [x] ER diagram + data dictionary
- [x] Database creation & configuration scripts
- [x] Table creation & realistic population (200+ users, 1200 secure_data rows)
- [x] PL/SQL package `security_pkg` with business rules & audit functions
- [x] Triggers that enforce weekday & holiday restrictions
- [x] Audit logging and simulated alerting
- [x] Analytics queries (window functions, aggregates) & dashboard plan
- [x] Presentation slides + screenshots folder

## Notes & future work
- For real alerts integrate `UTL_SMTP` or `UTL_MAIL` and secure credentials in a wallet.
- Export audit logs to SIEM (Splunk/ELK) for advanced correlation.
- Add retention and archival policies for audit_log and audit_details.

## Contact
If you need run help or modifications for your environment, contact me at victoireushindi371@gmail.com or include an issue in your GitHub repo.
# Smart-Intrusion-Alert-and-Audit-System-Using-PLSQL-Triggers-and-Logs
