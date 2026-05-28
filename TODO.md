# TODO - Edit Question System

## Plan (approved to implement)
- [ ] Update `client/src/services/quizService.js` to add:
  - `updateQuestion(quizId, questionId, data)` -> `PUT /quizzes/:id/questions/:questionId`
  - (if missing) ensure `deleteQuestion` helper exists
- [ ] Update backend routes/controllers/services to support editing questions:
  - Add `PUT /:id/questions/:questionId` route
  - Implement controller handler calling quizService updateQuestion
  - Implement `updateQuestion` in `server/services/quizService.js` to update question + replace choices safely
- [ ] Update `client/src/pages/QuizzesPage.js`:
  - Add state:
    - `editingQuestion`, `showEditModal`, `editQForm`, `editLoading`, validation/errors, `editErrors`
  - Add per-question action buttons in each question card:
    - ✏ Edit Question
    - 🗑 Delete Question
  - Implement modal/form reusing Add Question UI patterns, but prefilled with selected question
  - Implement `handleEditQuestion(question)` and `handleUpdateQuestion()`
  - Implement delete confirmation + `handleDeleteQuestion(quizId, questionId)`
  - Refresh quiz questions after update/delete
  - Add inline validation & prevent empty choices / ensure correct answer

## Testing / Verification
- [ ] Run frontend build/lint (if available)
- [ ] Manually test:
  - Edit MC question: change text/type/choices/correct choice/points and save
  - Edit TF question: switch true/false and save
  - Delete question refreshes list
  - Validation errors show

