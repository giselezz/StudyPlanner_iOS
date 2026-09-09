//
//  File.swift
//  StudyPlanner
//
//  Created by Yufan on 9/9/2026.
//

import Foundation

struct StudySession: Codable, Identifiable {
    var id = UUID()
    var taskTitle: String
    var startsAt: Date
    var durationMinutes: Int
    var isCompleted = false
    
    var endsAt: Date {
        startsAt.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }
}


struct AssignmentStudyPlan: Codable, Identifiable {
    var id = UUID()
    var assignment: UniversityAssignment
    var sessions: [StudySession]
    var isApproved = false
    
    var progress: Double {
        guard !sessions.isEmpty else {
            return 0
        }
        let completedSessions = sessions.filter { $0.isCompleted }
        return Double(completedSessions.count) / Double(sessions.count)
    }
}

