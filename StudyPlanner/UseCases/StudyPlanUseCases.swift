//
//  StudyPlanUseCases.swift
//  StudyPlanner
//
//  Created by Yufan on 9/9/2026.
//

import Foundation

enum StudyPlanGenerationError: LocalizedError, Equatable {
    case blankTitle
    case deadlinePassed
    case invalidWorkload
    
    var errorDescription: String? {
        switch self {
        case .blankTitle:
            return "Study plan title cannot be blank."
        case .deadlinePassed:
            return "Deadline cannot be in the past."
        case .invalidWorkload:
            return "Choose a total study time between 1 and 100 hours."
        }
    }
}


struct GenerateStudyPlanUseCase {
    func execute(
        assignment: UniversityAssignment,
        now: Date = Date()
    ) throws -> AssignmentStudyPlan {
        let title = assignment.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else {
            throw StudyPlanGenerationError.blankTitle
        }
        
        guard assignment.dueDate > now else {
            throw StudyPlanGenerationError.deadlinePassed
        }
        
        guard (1...100).contains(assignment.estimatedWorkloadHours) else {
            throw StudyPlanGenerationError.invalidWorkload
        }
        
        var cleanedAssignment = assignment
        cleanedAssignment.title = title
        
        let tasks = assignment.type.suggestedTasks
        let weights = assignment.type.workloadWeights
        let totalMinutes = assignment.estimatedWorkloadHours * 60
        let totalWeight = weights.reduce(0, +)
        var remainingMinutes = totalMinutes
        
        let sessions = tasks.enumerated().map { index, task in
            let minutes = index == tasks.count - 1 ? remainingMinutes : totalMinutes * weights[index] / totalWeight
            
            remainingMinutes -= minutes
            
            return StudySession(
                taskTitle: task,
                durationMinutes: minutes
            )
        }
        
        return AssignmentStudyPlan(
            assignment: cleanedAssignment,
            sessions: sessions
        )
    }
}
