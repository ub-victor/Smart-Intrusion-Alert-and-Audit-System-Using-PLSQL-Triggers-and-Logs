# PHASE III — Logical Model / ER Diagram + Data Dictionary

## Overview
**Process:** Secure Data Access & Intrusion Detection (logical model)

This document describes the main entities, relationships, a compact data dictionary, and sample DDL for creating the schema objects. Use an ER diagram tool (draw.io, Lucidchart, or Visio) to draw the ERD using these entities and relationships:

- **users** (PK: user_id)
- **secure_data** (PK: record_id, FK: owner_id -> users.user_id)
- **audit_log** (PK: log_id) — denormalized username text for historical accuracy
- **audit_details** — optional before/after payloads for writes
- **holidays** (PK: holiday_date)
- **roles** — optional lookup table
- **ip_context** — optional (map sessions to IP addresses — simulated for tests)

### Relationships
- `users (1) <-- (N) secure_data.owner_id`
- `secure_data` operations produce rows in `audit_log` (one-to-many)
- `audit_log.username` is a text snapshot (denormalized) to preserve historical user names

---

## ER Diagram guidance
Create the following entities and relationships in your diagram tool:
- Show PKs with a key icon and FK arrows between `secure_data.owner_id` -> `users.user_id`.
- Represent `audit_log` with a many relationship to the object tables (or a generic `table_name` column).
- Use optional `audit_details` related 1-to-1 or 1-to-many with `audit_log` (if a single write may generate multiple payload parts).
- Add indexes shown on `users.username`, `secure_data.owner_id`, `audit_log.action_time`, and `audit_log.ip_address`.

Recommended export: PNG or SVG for GitHub.

---

## Data Dictionary (short)

| Table | Column | Type | Constraint | Purpose |
|-------|--------|------|------------|---------|
| users | user_id | NUMBER | PK, NOT NULL | unique user id |
| users | username | VARCHAR2(50) | UNIQUE, NOT NULL | login name |
| users | role | VARCHAR2(20) | NOT NULL | e.g., EMPLOYEE, ADMIN |
| users | password_hash | VARCHAR2(200) | NOT NULL | hashed password |
| users | last_login | DATE | NULL | last login timestamp |
| secure_data | record_id | NUMBER | PK | sensitive record id |
| secure_data | owner_id | NUMBER | FK -> users.user_id | owner |
| secure_data | data_content | VARCHAR2(4000) |  | confidential content |
| secure_data | created_at | DATE | DEFAULT SYSDATE | created timestamp |
| audit_log | log_id | NUMBER | PK | audit event id |
| audit_log | username | VARCHAR2(50) |  | who attempted action (denormalized) |
| audit_log | action_type | VARCHAR2(20) |  | INSERT/UPDATE/DELETE |
| audit_log | table_name | VARCHAR2(50) |  | table targeted |
| audit_log | action_time | DATE | DEFAULT SYSDATE | timestamp |
| audit_log | ip_address | VARCHAR2(50) |  | client IP (simulated) |
| audit_log | alert_status | VARCHAR2(20) |  | NORMAL/SUSPICIOUS/DENIED |
| audit_log | details | CLOB |  | JSON or text describing action |
| audit_details | details_id | NUMBER | PK | payload storage for write operations |
| audit_details | log_id | NUMBER | FK -> audit_log.log_id | link back to audit_log |
| audit_details | before_payload | CLOB |  | optional before data snapshot |
| audit_details | after_payload | CLOB |  | optional after data snapshot |
| holidays | holiday_date | DATE | PK | public holiday date |
| holidays | description | VARCHAR2(200) |  | holiday name |
| roles | role_name | VARCHAR2(50) | PK | role lookup (optional) |
| ip_context | session_id | VARCHAR2(100) | PK | session identifier (simulated) |
| ip_context | user_id | NUMBER | FK -> users.user_id | session owner |
| ip_context | ip_address | VARCHAR2(50) |  | last known IP for session |

---

## Suggested SQL DDL (Oracle-compatible)

-- Sequences (if using NUMBER PKs)
```sql
CREATE SEQUENCE seq_users START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_secure_data START WITH 100000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_audit_log START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_audit_details START WITH 1 INCREMENT BY 1 NOCACHE;
```

-- Users table
```sql
CREATE TABLE users (
  user_id       NUMBER PRIMARY KEY,
  username      VARCHAR2(50) UNIQUE NOT NULL,
  role          VARCHAR2(20) NOT NULL,
  password_hash VARCHAR2(200) NOT NULL,
  last_login    DATE
);
```

-- Secure data table
```sql
CREATE TABLE secure_data (
  record_id    NUMBER PRIMARY KEY,
  owner_id     NUMBER NOT NULL,
  data_content VARCHAR2(4000),
  created_at   DATE DEFAULT SYSDATE,
  CONSTRAINT fk_secure_owner FOREIGN KEY (owner_id) REFERENCES users(user_id)
);
CREATE INDEX idx_secure_owner ON secure_data(owner_id);
```

-- Audit log
```sql
CREATE TABLE audit_log (
  log_id      NUMBER PRIMARY KEY,
  username    VARCHAR2(50),
  action_type VARCHAR2(20),
  table_name  VARCHAR2(50),
  action_time DATE DEFAULT SYSDATE,
  ip_address  VARCHAR2(50),
  alert_status VARCHAR2(20),
  details     CLOB
);
CREATE INDEX idx_audit_time ON audit_log(action_time);
CREATE INDEX idx_audit_ip ON audit_log(ip_address);
```

-- Audit details (optional)
```sql
CREATE TABLE audit_details (
  details_id     NUMBER PRIMARY KEY,
  log_id         NUMBER NOT NULL,
  before_payload CLOB,
  after_payload  CLOB,
  CONSTRAINT fk_audit_log FOREIGN KEY (log_id) REFERENCES audit_log(log_id)
);
```

-- Holidays
```sql
CREATE TABLE holidays (
  holiday_date DATE PRIMARY KEY,
  description  VARCHAR2(200)
);
```

-- Optional roles lookup
```sql
CREATE TABLE roles (
  role_name VARCHAR2(50) PRIMARY KEY,
  description VARCHAR2(200)
);
```

-- Optional ip_context
```sql
CREATE TABLE ip_context (
  session_id VARCHAR2(100) PRIMARY KEY,
  user_id    NUMBER,
  ip_address VARCHAR2(50),
  last_seen  DATE,
  CONSTRAINT fk_ip_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

---

## PHASE IV — Database creation (user & tablespace guidance)

If you have DBA rights, run as SYS/SYSTEM to create two tablespaces and create a project user. If not, skip tablespace creation and run the schema DDL as your assigned schema user.

**Script (run as SYSDBA)**

```sql
-- 01_create_user_and_tablespaces.sql  (run as SYS)
CREATE TABLESPACE project_data DATAFILE 'project_data01.dbf' SIZE 200M AUTOEXTEND ON NEXT 50M;
CREATE TABLESPACE project_idx  DATAFILE 'project_idx01.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M;

CREATE USER ushindi IDENTIFIED BY Ushindi2025
  DEFAULT TABLESPACE project_data
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON project_data;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE, CREATE TABLE TO ushindi;
-- Optional: grant select_catalog_role if you need SYS_CONTEXT calls
GRANT SELECT ON V_$DATABASE TO ushindi;
```

If you cannot run tablespace creation, use your existing schema (for example `student`) and run the DDL above after switching to that user.

### How to run in VS Code or SQL Developer
- Install Oracle Developer Tools for VS Code or use SQLcl.
- Or use Oracle SQL Developer: connect, open SQL Worksheet, paste scripts, run.

---

## Notes & Testing
- For tests, create a small set of users (EMPLOYEE/ADMIN/AUDITOR) and seed the `holidays` table with a few dates.
- Use `ip_context` to simulate different client IP addresses.
- Insert audit rows from triggers/packages in `security_pkg` (Phase II) to validate the pipeline.

---

## Deliverables for Phase III/IV
- ER diagram exported to PNG/SVG (draw.io / Lucidchart)
- `phaseIII_IV_db_schema.md` (this file)
- SQL DDL files (separate) containing the `CREATE TABLE` scripts and sequences

---
