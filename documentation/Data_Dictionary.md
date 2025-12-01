# Data Dictionary

## users
- user_id NUMBER PK
- username VARCHAR2(50) NOT NULL UNIQUE
- role VARCHAR2(20)
- password_hash VARCHAR2(200)
- last_login DATE

## secure_data
- record_id NUMBER PK
- owner_id NUMBER FK -> users(user_id)
- data_content VARCHAR2(4000)
- created_at DATE DEFAULT SYSDATE

## holidays
- holiday_date DATE PK
- description VARCHAR2(200)

## audit_log
- log_id NUMBER PK
- username VARCHAR2(50)
- action_type VARCHAR2(20)
- table_name VARCHAR2(50)
- action_time DATE DEFAULT SYSDATE
- ip_address VARCHAR2(50)
- alert_status VARCHAR2(20)
- details CLOB

## audit_details
- detail_id NUMBER PK
- log_id NUMBER FK -> audit_log(log_id)
- column_name VARCHAR2(100)
- old_value CLOB
- new_value CLOB
