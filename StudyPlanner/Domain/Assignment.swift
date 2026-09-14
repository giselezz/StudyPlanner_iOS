//
//  Assignment.swift
//  StudyPlanner
//
//  Created by Yufan on 6/9/2026.
//

import Foundation

/// Describes how an assessment format breaks work into study tasks.
///
/// Provides academic task names and their relative workload weights.
/// Each task must have a matching positive weight.
///
/// Generation uses these proportions to suggest durations.
/// They are starting estimates, not guaranteed study times.

protocol StudyTaskTemplate {
    var suggestedTasks: [String] { get }
    var workloadWeights: [Int] { get }
}

/// An assessment format, such as an essay, report or presentation. 
///
/// Each format supplies suggested academic tasks and workload weights.
/// Students can review the resulting durations before approving a plan.

enum AssignmentType: String, CaseIterable, Codable, StudyTaskTemplate {
    case essay = "Essay"
    case report = "Report"
    case presentation = "Presentation"
    
    var suggestedTasks: [String] {
        switch self {
        case .essay:
            return ["Research", "Outline", "Draft", "Edit"]
        case .report:
            return ["Research", "Structure report", "Write findings", "Review and edit"]
        case .presentation:
            return ["Research", "Create slides", "Rehearse", "Review"]
        }
    }
    
    var workloadWeights: [Int] {
        switch self {
        case .essay, .report:
            return [2, 1, 4, 1]
        case .presentation:
            return [2, 3, 2, 1]
        }
    }
}

/// A university assignment that a student wants to create a study plan for.
///
/// Stores the assignment's title, type, submission deadline and
/// estimated total workload in hours.
///
/// Business rules: generating a plan requires a title that is not blank after trimming whitespace,
/// a deadline later than the current time,
/// and an estimated workload between 1 and 100 hours.
///
/// GenerateStudyPlanUseCase enforces these rules;
/// this model stores the assignment details.

struct UniversityAssignment: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: AssignmentType
    var dueDate: Date
    var estimatedWorkloadHours: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        type: AssignmentType,
        dueDate: Date,
        estimatedWorkloadHours: Int = 8
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.dueDate = dueDate
        self.estimatedWorkloadHours = estimatedWorkloadHours
    }
}
