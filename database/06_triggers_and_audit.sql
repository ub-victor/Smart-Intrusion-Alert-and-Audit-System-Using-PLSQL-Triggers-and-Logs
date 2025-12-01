-- 06_triggers_and_audit.sql

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE CONTEXT project_ctx USING security_pkg';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE OR REPLACE PROCEDURE set_client_ip(p_ip IN VARCHAR2) AS
BEGIN
  EXECUTE IMMEDIATE 'BEGIN DBMS_SESSION.SET_CONTEXT(''project_ctx'',''CLIENT_IP'',''' || p_ip || '''); END;';
END;
/
CREATE OR REPLACE TRIGGER trg_secure_data_audit
FOR INSERT OR UPDATE OR DELETE ON secure_data
COMPOUND TRIGGER

  g_action VARCHAR2(20);

  BEFORE STATEMENT IS
  BEGIN
    IF INSERTING THEN g_action := 'INSERT';
    ELSIF UPDATING THEN g_action := 'UPDATE';
    ELSIF DELETING THEN g_action := 'DELETE';
    END IF;
  END BEFORE STATEMENT;

  BEFORE EACH ROW IS
    v_username VARCHAR2(50);
    v_role VARCHAR2(20);
    v_ip VARCHAR2(50);
  BEGIN
    BEGIN
      SELECT username, role INTO v_username, v_role
      FROM users
      WHERE username = SYS_CONTEXT('USERENV','SESSION_USER') AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_username := SYS_CONTEXT('USERENV','SESSION_USER');
      v_role := 'EMPLOYEE';
    END;

    SELECT NVL(SYS_CONTEXT('project_ctx','CLIENT_IP'), '0.0.0.0') INTO v_ip FROM DUAL;

    security_pkg.check_business_rules(v_username, v_role, g_action, 'SECURE_DATA', v_ip);

  END BEFORE EACH ROW;

  AFTER EACH ROW IS
  BEGIN
    NULL;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    NULL;
  END AFTER STATEMENT;

END trg_secure_data_audit;
/
