//
//  Assignment.swift
//  StudyPlanner
//
//  Created by Yufan on 6/9/2026.
//

import Foundation


enum AssignmentType: String, CaseIterable, Codable {
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
