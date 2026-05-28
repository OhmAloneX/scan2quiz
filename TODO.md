# TODO - Fix Multiple Choice & True/False input handling (QuizzesPage.js)

- [ ] Analyze current `client/src/pages/QuizzesPage.js` question form rendering.
- [x] Update Multiple Choice UI: render editable input fields for each choice + radio buttons.
- [x] Restore state update logic for Multiple Choice: typing updates `choices[i].text`, selecting correct updates `isCorrect` with only one true.
- [x] Update True/False UI: render radio buttons for True/False and ensure `qForm.tfCorrect` and `qForm.choices` update consistently.

- [ ] Ensure conditional rendering between `multiple_choice` and `true_false` remains intact and JSX tags are properly closed.
- [ ] Remove unused imports/variables if any.
- [ ] Run frontend lint/test or at least `npm test`/`npm run build` (as feasible) to confirm no ESLint/compile errors.

