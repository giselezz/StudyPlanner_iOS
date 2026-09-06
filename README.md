# StudyPlanner

A SwiftUI iOS app that helps university students break assignments into manageable study tasks, track progress and reschedule missed work.

## Project Status

Initial Xcode project setup. The features and architecture below describe the planned MVP and are not yet implemented.

## Domain and Stakeholder

University students balance assignment deadlines with classes, employment and personal commitments. Large assessments can be difficult to start, and missing a study session can leave students unsure how to reorganise their work.

StudyPlanner will support students by suggesting academic task templates, keeping submission deadlines visible and allowing students to review their plans and reschedule unfinished work.

## Planned MVP

1. Enter an assignment title, assessment type and submission deadline.
2. Generate suggested tasks from a fixed template, such as research, outline, draft and edit for an essay.
3. Review task dates and approve the study plan.
4. Track completion and reschedule missed study sessions before submission.

Students will select study dates themselves. Automatic scheduling and AI interpretation of assignment briefs are outside the initial scope.

## Four Planned Screens

- **Assignment List:** view assignments and access the assignment-entry screen.
- **New Assignment:** enter assessment details and generate a draft plan.
- **Study Plan Review:** review suggested tasks and dates, then approve the plan.
- **Assignment Detail:** view progress, mark work complete and reschedule missed sessions.

## Planned Architecture

SwiftUI Views → ViewModel → Use Case structs → Domain Models and Repository → Local Storage

Domain records will use structs. Shared presentation state will use a class. A study-plan repository protocol will separate saving and retrieving academic plans from storage details.

The three primary Use Cases will be:

- `GenerateStudyPlanUseCase`
- `ApproveStudyPlanUseCase`
- `RescheduleMissedStudySessionUseCase`

Each Use Case will define typed domain errors with messages explaining what the student can do next. Significant additional business operations will also follow the required Use Case structure.

## Initial Business Rules

- Assignment titles cannot be blank.
- A submission deadline must be in the future when generating a plan.
- A plan must contain study tasks before it can be approved.
- Planned sessions must finish before the submission deadline.
- An approved plan cannot be approved again.
- Completed sessions cannot be rescheduled.
- A replacement session must be in the future and finish before submission.
- Rescheduling must retain the unfinished work.

## Testing and Documentation

The project will include at least eight meaningful unit tests covering the three primary Use Cases. Each will have happy-path and failure coverage, with additional tests for business-rule boundaries and major errors.

Core domain models will have DocC comments explaining their real-world meaning and business rules. The assessment also requires a one-page Human-System Architecture diagram and a 600–800-word reflective report.

## Running the Project

1. Clone the repository using GitHub Desktop or Git.
2. Open `StudyPlanner.xcodeproj` in Xcode on a Mac.
3. Select the `StudyPlanner` scheme and a compatible iPhone simulator.
4. Choose **Product → Run**.
5. Choose **Product → Test** to run the available tests.

Currently, the app displays the starter screen. Domain tests will be added during implementation. Tested Xcode and iOS versions will be recorded before submission.

## Out of Scope

- AI assignment-brief analysis
- Automatic availability-based scheduling
- Apple Calendar integration
- Home-screen widgets
- Accounts and cloud synchronisation

## Assessment Context

Individual project for Assessment 2 in **40005 Advanced iOS Development**. The implementation will aim to stay compact while preserving the required screens, domain architecture, error handling and tests.
