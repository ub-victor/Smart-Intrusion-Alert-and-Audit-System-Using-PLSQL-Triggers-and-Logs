-- 05_packages_and_functions.sql
CREATE OR REPLACE PACKAGE security_pkg AS
  PROCEDURE log_audit(p_username IN VARCHAR2, p_action IN VARCHAR2, p_table IN VARCHAR2, p_ip IN VARCHAR2, p_status IN VARCHAR2, p_details IN CLOB);
  PROCEDURE send_alert(p_username IN VARCHAR2, p_table IN VARCHAR2, p_action IN VARCHAR2, p_ip IN VARCHAR2, p_reason IN VARCHAR2);
  FUNCTION is_public_holiday(p_date IN DATE) RETURN BOOLEAN;
  FUNCTION is_weekday(p_date IN DATE) RETURN BOOLEAN;
  PROCEDURE check_business_rules(p_username IN VARCHAR2, p_role IN VARCHAR2, p_action IN VARCHAR2, p_table IN VARCHAR2, p_ip IN VARCHAR2);
END security_pkg;
/
CREATE OR REPLACE PACKAGE BODY security_pkg AS 

  PROCEDURE log_audit(p_username IN VARCHAR2, p_action IN VARCHAR2, p_table IN VARCHAR2, p_ip IN VARCHAR2, p_status IN VARCHAR2, p_details IN CLOB) IS
    v_log_id NUMBER;
  BEGIN
    v_log_id := seq_audit_log.NEXTVAL;
    INSERT INTO audit_log (log_id, username, action_type, table_name, action_time, ip_address, alert_status, details)
    VALUES (v_log_id, p_username, p_action, p_table, SYSDATE, p_ip, p_status, p_details);
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END log_audit;

  PROCEDURE send_alert(p_username IN VARCHAR2, p_table IN VARCHAR2, p_action IN VARCHAR2, p_ip IN VARCHAR2, p_reason IN VARCHAR2) IS
    v_message VARCHAR2(4000);
  BEGIN
    v_message := 'ALERT: '||p_reason||' by '||nvl(p_username,'UNKNOWN')||' action='||p_action||' table='||p_table||' ip='||p_ip||' at '||TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS');
    DBMS_OUTPUT.PUT_LINE(v_message);
    security_pkg.log_audit(p_username, p_action, p_table, p_ip, 'SUSPICIOUS', TO_CLOB(v_message));
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END send_alert;

  FUNCTION is_public_holiday(p_date IN DATE) RETURN BOOLEAN IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM holidays WHERE TRUNC(holiday_date) = TRUNC(p_date);
    RETURN v_count > 0;
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END is_public_holiday;

  FUNCTION is_weekday(p_date IN DATE) RETURN BOOLEAN IS
    v_dayname VARCHAR2(10) := LOWER(TO_CHAR(p_date,'DY','NLS_DATE_LANGUAGE=ENGLISH'));
  BEGIN
    IF v_dayname IN ('sat','sun') THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RETURN TRUE;
  END is_weekday;

  PROCEDURE check_business_rules(p_username IN VARCHAR2, p_role IN VARCHAR2, p_action IN VARCHAR2, p_table IN VARCHAR2, p_ip IN VARCHAR2) IS
    v_now DATE := SYSDATE;
    v_details CLOB := TO_CLOB('Check at '||TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')||' for user='||nvl(p_username,'UNKNOWN'));
    v_status VARCHAR2(20) := 'NORMAL';
  BEGIN
    IF p_role = 'EMPLOYEE' THEN
      IF is_weekday(v_now) THEN
        v_status := 'DENIED';
        security_pkg.log_audit(p_username, p_action, p_table, p_ip, v_status, v_details);
        RAISE_APPLICATION_ERROR(-20001, 'Business Rule Violation: Employees cannot perform this action on weekdays.');
      END IF;
      IF is_public_holiday(v_now) THEN
        v_status := 'DENIED';
        security_pkg.log_audit(p_username, p_action, p_table, p_ip, v_status, v_details);
        RAISE_APPLICATION_ERROR(-20002, 'Business Rule Violation: Employees cannot perform this action on a public holiday.');
      END IF;
    END IF;

    IF p_action = 'DELETE' AND p_role NOT IN ('ADMIN','AUDITOR') THEN
      security_pkg.send_alert(p_username, p_table, p_action, p_ip, 'DELETE attempt by non-admin');
    END IF;

    security_pkg.log_audit(p_username, p_action, p_table, p_ip, 'NORMAL', v_details);
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-20001,-20002) THEN
      security_pkg.log_audit(p_username, p_action, p_table, p_ip, 'ERROR', TO_CLOB(SQLERRM));
    END IF;
    RAISE;
  END check_business_rules;

END security_pkg;
/
