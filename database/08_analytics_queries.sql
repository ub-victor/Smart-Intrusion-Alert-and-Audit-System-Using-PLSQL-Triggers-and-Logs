-- 08_analytics_queries.sql

-- 1. Basic KPIs
SELECT
  (SELECT COUNT(*) FROM audit_log) AS total_events,
  (SELECT COUNT(*) FROM audit_log WHERE alert_status='DENIED') AS total_denied,
  (SELECT COUNT(*) FROM audit_log WHERE alert_status='SUSPICIOUS') AS total_suspicious,
  (SELECT COUNT(*) FROM audit_log WHERE action_time >= SYSDATE - 7) AS last_7days_events
FROM DUAL;

-- 2. Top offending users
SELECT username, COUNT(*) AS attempts
FROM audit_log
GROUP BY username
ORDER BY attempts DESC
FETCH FIRST 10 ROWS ONLY;

-- 3. Actions by hour (heat)
SELECT TO_CHAR(action_time,'HH24') hour_of_day, action_type, COUNT(*) cnt
FROM audit_log
GROUP BY TO_CHAR(action_time,'HH24'), action_type
ORDER BY hour_of_day, action_type;

-- 4. Denied attempts per day (last 30 days)
SELECT TRUNC(action_time) dt, COUNT(*) denied_count
FROM audit_log
WHERE alert_status = 'DENIED' AND action_time >= SYSDATE - 30
GROUP BY TRUNC(action_time)
ORDER BY dt;

-- 5. Window function example: last action per user
SELECT username, action_type, action_time,
       ROW_NUMBER() OVER (PARTITION BY username ORDER BY action_time DESC) rn
FROM audit_log
WHERE username IS NOT NULL
AND rownum <= 1000
ORDER BY username, action_time DESC;

-- 6. Suspicious events with details
SELECT log_id, username, action_type, TO_CHAR(action_time,'YYYY-MM-DD HH24:MI:SS') ts, ip_address, alert_status, DBMS_LOB.SUBSTR(details, 4000, 1) details
FROM audit_log
WHERE alert_status IN ('SUSPICIOUS','DENIED')
ORDER BY action_time DESC;
