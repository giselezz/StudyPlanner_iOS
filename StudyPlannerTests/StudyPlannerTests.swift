//
//  StudyPlannerTests.swift
//  StudyPlannerTests
//
//  Created by Yufan on 6/9/2026.
//

import XCTest
@testable import StudyPlanner

final class StudyPlannerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 2000000000)
    
    private func essay(
        title: String = "History Essay",
        dueAfter seconds: TimeInterval = 86400
    ) -> UniversityAssignment {
        UniversityAssignment(
            title: title,
            type: .essay,
            dueDate: now.addingTimeInterval(seconds),
        )
    }
    
    func test_generateEssayPlan_createsUnscheduledDraft() throws {
        let plan = try GenerateStudyPlanUseCase().execute(
            assignment: essay(),
            now: now
        )
        
        XCTAssertEqual(
            plan.sessions.map(\.taskTitle),
            ["Research", "Outline", "Draft", "Edit"]
        )
        XCTAssertFalse(plan.isApproved)
        XCTAssertTrue(plan.sessions.allSatisfy {
            $0.startsAt == nil
        })
        
        XCTAssertEqual(
            plan.sessions.map { $0.durationMinutes },
            [120, 60, 240, 60]
        )
    }
    
    func test_generatePlan_rejectsWhitespaceOnlyTitle() {
        XCTAssertThrowsError(
            try GenerateStudyPlanUseCase().execute(
                assignment: essay(
                    title: "    "),
                now: now
            )
        ) { error in
                XCTAssertEqual(error as? StudyPlanGenerationError, .blankTitle)
        }
    }
    
    func test_generatePlan_rejectsDeadlineAtCurrentTime() {
        XCTAssertThrowsError(
            try GenerateStudyPlanUseCase().execute(
                assignment: essay(
                    dueAfter: 0
                ),
                now: now
            )
        ) { error in
            XCTAssertEqual(error as? StudyPlanGenerationError, .deadlinePassed)
        }
    }
    
    
    func test_approvePlan_acceptsValidSession() throws {
        let plan = AssignmentStudyPlan(
            assignment: essay(),
            sessions: [
                StudySession(taskTitle: "Research", startsAt: now.addingTimeInterval(3600), durationMinutes: 60)
            ]
        )
        
        let approved = try ApproveStudyPlanUseCase().execute(plan: plan, now: now)
        
        XCTAssertTrue(approved.isApproved)
        XCTAssertEqual(approved.id, plan.id)
        XCTAssertFalse(plan.isApproved)
    }
    
    func test_approvePlan_rejectsMissingStartTime() {
        let plan = AssignmentStudyPlan(
            assignment: essay(),
            sessions: [
                StudySession(taskTitle: "Research", durationMinutes: 60)
            ]
        )
        
        XCTAssertThrowsError(
            try ApproveStudyPlanUseCase().execute(plan: plan, now: now)
        ) { error in
            XCTAssertEqual(error as? StudyPlanApprovalError, .missingStart("Research"))
        }
    }
    
    func test_approvePlan_rejectsZeroDuration() {
        let plan = AssignmentStudyPlan(
            assignment: essay(),
            sessions: [
                StudySession(taskTitle: "Research", startsAt: now.addingTimeInterval(3600), durationMinutes: 0)
            ]
        )
        
        XCTAssertThrowsError(
            try ApproveStudyPlanUseCase().execute(plan: plan, now: now)
        ) { error in
            XCTAssertEqual(error as? StudyPlanApprovalError, .invalidDuration("Research"))
        }
    }
    
    func test_approvePlan_rejectsFinishAfterDeadline() {
        let plan = AssignmentStudyPlan(
            assignment: essay(dueAfter: 7200),
            sessions: [
                StudySession(taskTitle: "Research", startsAt: now.addingTimeInterval(3600), durationMinutes: 61)
            ]
        )
        
        XCTAssertThrowsError(
            try ApproveStudyPlanUseCase().execute(plan: plan, now: now)
        ) { error in
            XCTAssertEqual(error as? StudyPlanApprovalError, .finishesAfterDeadline("Research"))
        }
    }
    
    func test_approvePlan_rejectsOverlappingSessions() {
        let plan = AssignmentStudyPlan(
            assignment: essay(),
            sessions: [
                StudySession(taskTitle: "Research", startsAt: now.addingTimeInterval(3600), durationMinutes: 60),
                StudySession(taskTitle: "Outline", startsAt: now.addingTimeInterval(5400), durationMinutes: 30)
            ]
        )
        
        XCTAssertThrowsError(
            try ApproveStudyPlanUseCase().execute(plan: plan, now: now)
        ) { error in
            XCTAssertEqual(error as? StudyPlanApprovalError, .overlappingSessions)
        }
    }
}

