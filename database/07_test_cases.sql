-- 07_test_cases.sql
SET SERVEROUTPUT ON SIZE 1000000;

BEGIN
  set_client_ip('10.0.0.15');
END;
/

SELECT TO_CHAR(SYSDATE,'DY, DD-MON-YYYY HH24:MI:SS') CURRENT_DAY FROM DUAL;

-- Ensure a users row exists for the DB session user
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM users WHERE username = USER;
  IF v_count = 0 THEN
    INSERT INTO users (user_id, username, role, password_hash) VALUES (seq_users.NEXTVAL, USER, 'EMPLOYEE', 'HASH_TEST');
    COMMIT;
  END IF;
END;
/

-- Attempt INSERT (may be denied for EMPLOYEE on weekday)
BEGIN
  INSERT INTO secure_data(record_id, owner_id, data_content) VALUES (seq_secure_data.NEXTVAL, (SELECT user_id FROM users WHERE username = USER AND ROWNUM=1), 'Test insert by '||USER);
  DBMS_OUTPUT.PUT_LINE('Insert succeeded.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Insert failed: '||SQLERRM);
END;
/

-- Promote to ADMIN for testing allowed flow
UPDATE users SET role='ADMIN' WHERE username = USER;
COMMIT;

BEGIN
  INSERT INTO secure_data(record_id, owner_id, data_content) VALUES (seq_secure_data.NEXTVAL, (SELECT user_id FROM users WHERE username = USER AND ROWNUM=1), 'Admin test insert by '||USER);
  DBMS_OUTPUT.PUT_LINE('Admin insert succeeded.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Admin insert failed: '||SQLERRM);
END;
/

-- Reset role to EMPLOYEE
UPDATE users SET role='EMPLOYEE' WHERE username = USER;
COMMIT;

-- Attempt DELETE (may be denied or trigger alert)
BEGIN
  DELETE FROM secure_data WHERE ROWNUM = 1;
  DBMS_OUTPUT.PUT_LINE('Delete attempted.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Delete failed: '||SQLERRM);
END;
/

-- Show last 20 audit_log entries
SELECT * FROM (SELECT log_id, username, action_type, table_name, action_time, ip_address, alert_status FROM audit_log ORDER BY action_time DESC) WHERE ROWNUM <= 20;
