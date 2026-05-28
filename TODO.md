# TODO — Content Responsiveness Refinement

## Plan summary (safe, incremental)
1. Add/standardize a `brakepoints` object and mobile-friendly padding/gap helpers using the existing `useResponsive` hook. (No theme/sidebar changes.)
2. Fix worst offenders first: **AnalyticsPage.js**, **AdminPage.js**, **ScannerPage.js**.
   - Ensure cards and chart layout stack/resize on <=1024/768/480.
   - Prevent horizontal overflow on mobile (tables + charts).
   - Make camera/scanner viewport fit without exceeding width.
3. Then iterate page-by-page for remaining requested files: 
   - DashboardPage.js, QuizPage.js, QuizzesPage.js, SessionsPage.js, StudentsPage.js, TakeQuizPage.js, JoinPage.js.
4. For tables: keep current desktop table behavior, but on mobile enable `overflowX:auto` and reduce `minWidth`; optionally convert to stacked rows only where required.
5. For forms and grids: switch multi-column to single column at breakpoints, reduce fixed paddings, and use `gap` adjustments.
6. Run a quick build/test (npm test/build) to ensure no runtime regressions.

## Step tracking
- [ ] Inspect current responsiveness issues page-by-page (already started for Analytics/Admin/Scanner).
- [ ] Apply first set of targeted code edits (AnalyticsPage.js, AdminPage.js, ScannerPage.js).
- [ ] Verify no horizontal scrolling + touch target sizing on mobile widths.
- [ ] Apply remaining page edits in the requested order.
- [ ] Validate with quick local build.

