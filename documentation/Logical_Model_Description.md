# Logical Model Description

Entities:
- users
- secure_data
- audit_log
- audit_details
- holidays

Relationships:
- users 1..* secure_data (owner)
- audit_log references users by username (denormalized for historical accuracy)
