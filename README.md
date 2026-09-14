# StudyPlanner

## Project Overview

StudyPlanner is a SwiftUI iOS app that helps university students break assignments into smaller study tasks. Students enter an assignment’s details and estimated workload, then receive suggested tasks and durations. 

They can review the suggestions, choose study times and approve their plan. Saved plans support tracking task completion, rescheduling unfinished sessions and deleting plans that are no longer needed. 

## Implemented Features

- **Assignment entry:** Enter a title, assignment type, submission deadline and estimated workload. 
- **Task suggestions:** Generate tasks and suggested durations for essays, reports and presentations. 
- **Plan review:** Adjust task durations and choose study start times before approval. 
- **Schedule validation:** Check for missing times, invalid durations, past starts, overlapping sessions and sessions finishing after the deadline. 
- **Approval confirmation:** Confirm successful approval and saving, with buttons to return home or view plan details. 
- **Saved plans:** Browse plans in deadline order and view task-completion progress. 
- **Task completion:** Mark individual study sessions as completed. 
- **Rescheduling:** Move unfinished sessions while keeping their durations and checking for conflicts within the same plan. 
- **Plan deletion:** Delete a saved plan through a confirmation sheet with Cancel and Delete actions. 
- **Local storage:** Save approved plans and subsequent changes as JSON so they remain available after relaunching the app. 

## Domain Context

University students often balance assignments with classes, part-time work and personal commitments. Knowing a submission deadline does not always make it clear how to start or divide the workload. 

StudyPlanner provides a starting point through task templates for essays, reports and presentations. Suggested durations are editable estimates, while students choose start times based on their own availability. The app checks scheduling rules but does not read assignment briefs or automatically organise the student’s timetable. 

## Architecture Summary

The app uses MVVM with a separate Use Case layer. 

- **Views:** SwiftUI screens display plans, collect input and show feedback.
- **ViewModel:** `StudyPlannerViewModel` manages shared state, navigation and coordination between use cases and storage. 
- **Use Cases:** `GenerateStudyPlanUseCase`, `ApproveStudyPlanUseCase`, `CompleteStudySessionUseCase` and `RescheduleStudySessionUseCase` enforce business rules such as valid deadlines, positive durations and non-overlapping sessions. 
- **Domain Models:** `UniversityAssignment`, `StudySession` and `AssignmentStudyPlan` represent the assignment and its planned work. `AssignmentType` provides task templates and workload proportions. 
- **Repository:** `StudyPlanRepository` separates persistence from its JSON implementation. `JSONStudyPlanRepository` stores plans in the app’s Documents directory. 

Domain records use structs, while the ViewModel uses a class because multiple screens share its mutable state. Use cases return updated records, and the ViewModel coordinates saving them. 

Deletion currently runs directly through the ViewModel and repository rather than a dedicated use case. 

## Setup Instructions

1. Clone or download the repository. 
2. Open `StudyPlanner.xcodeproj` in Xcode. 
3. Use an Xcode version with the iOS 26.5 SDK and select an iPhone simulator running iOS 26.5 or later. 
4. Select the `StudyPlanner` scheme. 
5. Choose **Product > Run** to launch the app. 
6. Choose **Product > Test** to run the tests. 
