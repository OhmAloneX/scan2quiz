# Scan2Quiz — Audit Trail Implementation Checklist

## Phase 1 — Backend + DB + Audit endpoints
- [ ] Add `audit_logs` table to `database/schema.sql`
- [ ] Create `server/services/auditService.js`
- [ ] Create `server/middleware/auditContext.js`
- [ ] Create `server/routes/audit.js` (admin+teacher)
- [ ] Wire audit routes in `server/server.js`
- [ ] Wire audit context middleware in `server/server.js`
- [ ] Add audit logging in auth flows (login success/failure, barcode login, register, pending/admin actions)
- [ ] Add audit logging in quiz flows (quiz CRUD, question add/delete/update)
- [ ] Add audit logging in session flows (create/close/join, scan events, invalid QR/barcode)
- [ ] Add audit logging for suspicious patterns (multiple attempt detection, invalid QR)
- [ ] Add/adjust any typings/exports/imports to keep app running
- [ ] Quick backend smoke test: endpoints return and inserting audit rows does not break core flows

## Phase 2 — Frontend Audit UI (admin+teacher)
- [ ] Create `client/src/services/auditService.js`
- [ ] Create `client/src/pages/AuditLogsPage.js` (filters, pagination, search, severity badges)
- [ ] Add sidebar link for Audit Logs (admin+teacher)
- [ ] Add route protection + navigation
- [ ] Add dashboard widgets: Recent Activity, Security Alerts, Failed Login Summary, Most Active Users
- [ ] Implement daily activity chart or daily counts widget
- [ ] Mobile responsive behavior (table->cards)
- [ ] Quick frontend smoke test: audit page renders with empty state + data state


