//
//  File.swift
//  StudyPlanner
//
//  Created by Yufan on 9/9/2026.
//

import Foundation


/// A planned period of study for one task, such as researching an essay.
///
/// Generated sessions have suggested durations but no start times.
/// The student reviews the duration and chooses when to study.
///
/// Business rules: approval requires a start time, a positive duration,
/// and a session that starts no earlier than now and finishes by the assignment deadline.
/// Sessions in the plan must not overlap.
///
/// Completion is reported by the student.
/// Completed sessions cannot be rescheduled.
/// The use cases enforce these rules.

struct StudySession: Codable, Identifiable {
    var id = UUID()
    var taskTitle: String
    var startsAt: Date? = nil
    var durationMinutes: Int? = nil
    var isCompleted = false
    
    var endsAt: Date? {
        guard let start = startsAt, let minutes = durationMinutes else {
            return nil
        }
        return start.addingTimeInterval(Double(minutes) * 60)
    }
}

/// A study plan containing one university assignment and its sessions.
///
/// A new plan starts as an unapproved draft.
///
/// Business rules: approval requires at least one session and a valid,
/// non-overlapping schedule that finishes by the assignment deadline.
/// Completing or rescheduling a session requires an approved plan.
///
/// The plan contains its assignment and sessions through composition.
/// Use cases validate changes, while the repository handles storage.

struct AssignmentStudyPlan: Codable, Identifiable {
    var id = UUID()
    var assignment: UniversityAssignment
    var sessions: [StudySession]
    var isApproved = false
    
    /// The proportion of sessions marked complete, from 0 to 1.
    ///
    /// Each session counts equally, regardless of its duration.
    /// An empty plan returns 0.
    /// This does not measure assignment quality or the number of hours actually studied.
    
    var progress: Double {
        guard !sessions.isEmpty else {
            return 0
        }
        let completedSessions = sessions.filter { $0.isCompleted }
        return Double(completedSessions.count) / Double(sessions.count)
    }
}

