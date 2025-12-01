# BPMN Diagram & Explanation

(Process name: Secure Data Access & Intrusion Detection)

**Overview**
This BPMN diagram models how users interact with the system and how the database intercepts DML operations to enforce business rules and log activity.

**Actors**
- User (Employee / Admin / Auditor)
- Application (web UI / SQL Developer)
- Database (PL/SQL triggers & packages)
- DBA / Security Officer

**Key Decisions**
- Business rules enforced at DB layer for reliability.
- Audit trail captures username, action, timestamp, ip, status, and details.
- Suspicious activity triggers alerts and is logged for DBA review.
