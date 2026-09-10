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
    
    var errorDescription: String? {
        switch self {
        case .blankTitle:
            return "Study plan title cannot be blank."
        case .deadlinePassed:
            return "Deadline cannot be in the past."
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
        
        var cleanedAssignment = assignment
        cleanedAssignment.title = title
        
        let sessions = assignment.type.suggestedTasks.map {
            StudySession(taskTitle: $0)
        }
        
        return AssignmentStudyPlan(
            assignment: cleanedAssignment,
            sessions: sessions
        )
    }
}
