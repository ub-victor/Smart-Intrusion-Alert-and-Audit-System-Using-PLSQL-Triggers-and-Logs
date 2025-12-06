
# PHASE II — Business Process Modelling (BPMN/UML)

## Process name: Secure Data Access & Intrusion Detection

### **Scope**
Controls how users access/modify sensitive records (`secure_data`).  
Monitors all DML operations (INSERT/UPDATE/DELETE), enforces business rules, logs all attempts, and sends alerts when suspicious behavior is detected.

---

## Primary Actors

| Actor | Description |
|--------|-------------|
| User (Employee/Admin/Auditor) | Initiates data operations |
| Application | UI application or SQL client |
| Database | Triggers & auditing PL/SQL modules |
| DBA / Security Officer | Monitors and responds to alerts |

---

## Swimlanes
- **Users**
- **Application**
- **Database**
- **DBA / Security Officer**

---

## BPMN-Style Flow Summary

1. User initiates DML (INSERT/UPDATE/DELETE) on `secure_data`.
2. Database trigger intercepts action.
3. Calls `security_pkg.check_business_rules(action, table, user, ip)`
4. Decision:
   - If violation (weekday or holiday for standard employee) → DML aborted.
   - Else → proceed normally.
5. `security_pkg.log_audit(...)` records attempt (success or denial).
6. Security escalation logic:
   - Repeated denials from same user/IP → `security_pkg.send_alert(...)`
7. If allowed, DML completes.
8. Post-transaction audit entry saved (possible snapshot before/after).
9. DBA reviews dashboards & flagged logs.

---

## Decision Logic
| Condition | Outcome |
|----------|---------|
| Employee attempts write on weekday | ❌ Reject |
| Employee tries on public holiday | ❌ Reject |
| Admin performs operation | ✔ Allow |
| Auditor performs SELECT only | ✔ Allowed |
| Repeated denials from same IP | 🔔 Alert raised |