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
}



struct UniversityAssignment: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: AssignmentType
    var dueDate: Date
    
    init(id: UUID = UUID(), title: String, type: AssignmentType, dueDate: Date) {
        self.id = id
        self.title = title
        self.type = type
        self.dueDate = dueDate
    }
}
