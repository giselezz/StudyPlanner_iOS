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

enum StudyPlanApprovalError: LocalizedError, Equatable {
    case noSessions
    case missingStart(String)
    case invalidDuration(String)
    case startTimeInPast(String)
    case finishesAfterDeadline(String)
    case overlappingSessions
    
    var errorDescription: String? {
        switch self {
        case .noSessions:
            return "Generate some study tasks before approving."
        case .missingStart(let task):
            return "Choose a start time for \(task)."
        case .invalidDuration(let task):
            return "Study session for \(task) has invalid duration."
        case .startTimeInPast(let task):
            return "Choose a future start time for \(task)."
        case .finishesAfterDeadline(let task):
            return "Move \(task) earlier or shorten it to finish by the due date."
        case .overlappingSessions:
            return "Study sessions overlap. Adjust their times."
        }
    }
}

struct ApproveStudyPlanUseCase {
    func execute(
        plan: AssignmentStudyPlan,
        now: Date = Date()
    ) throws -> AssignmentStudyPlan {
        guard !plan.sessions.isEmpty else {
            throw StudyPlanApprovalError.noSessions
        }
        
        let sortedSessions = plan.sessions.sorted {
            (first: StudySession, second: StudySession) in
            (first.startsAt ?? Date.distantPast) < (second.startsAt ?? Date.distantPast)
        }
        var previousEnd: Date?
        
        for session in sortedSessions {
            guard let start = session.startsAt else {
                throw StudyPlanApprovalError.missingStart(session.taskTitle)
            }
            
            guard let minutes = session.durationMinutes, minutes > 0 else {
                throw StudyPlanApprovalError.invalidDuration(session.taskTitle)
            }
            
            guard start >= now else {
                throw StudyPlanApprovalError.startTimeInPast(session.taskTitle)
            }
            
            let end = start.addingTimeInterval(Double(minutes * 60))
            
            guard end <= plan.assignment.dueDate else {
                throw StudyPlanApprovalError.finishesAfterDeadline(session.taskTitle)
            }
            
            if let previousEnd, start < previousEnd {
                throw StudyPlanApprovalError.overlappingSessions
            }
            
            previousEnd = end
        }
        
        var approvedPlan = plan
        approvedPlan.isApproved = true
        return approvedPlan
    }
}

enum StudySessionCompletionError: LocalizedError, Equatable {
    case planNotApproved
    case sessionNotFound
    
    var errorDescription: String? {
        switch self {
        case .planNotApproved:
            return "Approve your study plan before completing tasks."
        case .sessionNotFound:
            return "This task could not be found. Reopen the plan and try again."
        }
    }
}

struct CompleteStudySessionUseCase {
    func execute(
        plan: AssignmentStudyPlan,
        sessionID: UUID) throws -> AssignmentStudyPlan {
            guard plan.isApproved else {
                throw StudySessionCompletionError.planNotApproved
            }
            
            guard let index = plan.sessions.firstIndex(where: {$0.id == sessionID}) else {
                throw StudySessionCompletionError.sessionNotFound
            }
            
            var updatedPlan = plan
            updatedPlan.sessions[index].isCompleted = true
            return updatedPlan
            
        }
}
