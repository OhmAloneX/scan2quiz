# TODO Audit Trail - AuditLogsPage redesign

- [x] Read current `client/src/pages/AuditLogsPage.js` and understand existing logic (filters, pagination, loading, role guard).
- [x] Read `LoginPage.js`, `DashboardPage.js`, `QuizzesPage.js`, `AdminPage.js` for the shared glassmorphism design language.
- [x] Read shared UI components: `GlassCard.js`, `Pagination.js`.
- [x] Implement redesign in `client/src/pages/AuditLogsPage.js`:

  - [ ] Replace page shell/header with consistent gradient + ambient blobs + title/subtitle.
  - [ ] Redesign search/filter toolbar using consistent glass input styles.
  - [ ] Replace pagination UI with `client/src/components/ui/Pagination.js`.
  - [ ] Redesign audit table (glass container, sticky header, hover effects, responsive scrolling).
  - [ ] Add status badges (Success/Warning/Failed) mapped from log severity.
  - [ ] Add loading spinner/skeletons and empty state (“No audit logs found.”).
  - [ ] Ensure role guard + audit fetching/filter/search/pagination behavior remains intact.
  - [ ] Cleanup unused imports/classes and ensure no ESLint/JSX breakage.
- [ ] Quick manual verification steps:
  - [ ] Confirm filters trigger fetch with correct params.
  - [ ] Confirm pagination works via shared component.
  - [ ] Confirm empty state and loading state render correctly.

