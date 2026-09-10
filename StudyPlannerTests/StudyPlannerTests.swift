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
            $0.startsAt == nil && $0.durationMinutes == nil
        })
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
    

}

