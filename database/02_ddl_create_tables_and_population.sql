-- 02_ddl_create_tables_and_population.sql
-- Connect as project user, e.g.: CONNECT ushindi/Ushindi2025;

-- Drop existing objects if any
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE audit_details CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE audit_log CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE secure_data CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE holidays CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_users';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_secure_data';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_audit_log';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
COMMIT;
/

-- Create tables
CREATE TABLE users (
  user_id      NUMBER PRIMARY KEY,
  username     VARCHAR2(50) UNIQUE NOT NULL,
  role         VARCHAR2(20) NOT NULL,
  password_hash VARCHAR2(200) NOT NULL,
  last_login   DATE
);

CREATE TABLE secure_data (
  record_id    NUMBER PRIMARY KEY,
  owner_id     NUMBER NOT NULL,
  data_content VARCHAR2(4000),
  created_at   DATE DEFAULT SYSDATE,
  CONSTRAINT fk_secure_owner FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE holidays (
  holiday_date DATE PRIMARY KEY,
  description  VARCHAR2(200)
);

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

CREATE TABLE audit_details (
  detail_id    NUMBER PRIMARY KEY,
  log_id       NUMBER,
  column_name  VARCHAR2(100),
  old_value    CLOB,
  new_value    CLOB,
  CONSTRAINT fk_audit_log FOREIGN KEY (log_id) REFERENCES audit_log(log_id) ON DELETE CASCADE
);

-- Sequences
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_secure_data START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_audit_log START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_audit_details START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Indexes
CREATE INDEX idx_secure_owner ON secure_data(owner_id);
CREATE INDEX idx_audit_time ON audit_log(action_time);

COMMIT;

-- Populate holidays
INSERT INTO holidays (holiday_date, description) VALUES (TO_DATE('2025-12-25', 'YYYY-MM-DD'), 'Christmas Day');
INSERT INTO holidays (holiday_date, description) VALUES (TO_DATE('2025-12-26', 'YYYY-MM-DD'), 'Boxing Day');
INSERT INTO holidays (holiday_date, description) VALUES (TO_DATE('2025-11-01', 'YYYY-MM-DD'), 'All Saints Day');
COMMIT;

-- Populate users & secure_data
DECLARE
  v_user_id NUMBER;
  v_name VARCHAR2(50);
  v_roles  SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('EMPLOYEE','EMPLOYEE','EMPLOYEE','ADMIN','AUDITOR');
BEGIN
  -- Insert known users
  v_user_id := seq_users.NEXTVAL;
  INSERT INTO users(user_id, username, role, password_hash, last_login)
  VALUES (v_user_id, 'admin', 'ADMIN', 'HASHED_ADMIN_PW', SYSDATE);

  v_user_id := seq_users.NEXTVAL;
  INSERT INTO users(user_id, username, role, password_hash, last_login)
  VALUES (v_user_id, 'auditor', 'AUDITOR', 'HASHED_AUDITOR_PW', SYSDATE - 10);

  -- Insert many employees
  FOR i IN 1..198 LOOP
    v_user_id := seq_users.NEXTVAL;
    v_name := 'user' || TO_CHAR(i, 'FM000');
    INSERT INTO users(user_id, username, role, password_hash)
      VALUES (v_user_id, v_name, v_roles((MOD(i, v_roles.COUNT) + 1)), 'HASH_' || v_name);
  END LOOP;

  COMMIT;

  -- Insert secure_data rows
  FOR j IN 1..1200 LOOP
    INSERT INTO secure_data(record_id, owner_id, data_content, created_at)
    VALUES (seq_secure_data.NEXTVAL,
            (SELECT user_id FROM (SELECT user_id FROM users WHERE role='EMPLOYEE' ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1),
            'Confidential dossier content ' || TO_CHAR(j),
            SYSDATE - DBMS_RANDOM.VALUE(0,365));
    IF MOD(j,100)=0 THEN COMMIT; END IF;
  END LOOP;
  COMMIT;
END;
/
