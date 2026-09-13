//
//  File.swift
//  StudyPlanner
//
//  Created by Yufan on 13/9/2026.
//

import Foundation

/// Loads and saves the student's study plans.
protocol StudyPlanRepository {
    func load() throws -> [AssignmentStudyPlan]
    func save(_ plans: [AssignmentStudyPlan]) throws
}

struct JSONStudyPlanRepository: StudyPlanRepository {
    private let fileURL: URL
    
    init() {
        fileURL = URL.documentsDirectory.appendingPathComponent("study_plans.json")
    }
    
    func load() throws -> [AssignmentStudyPlan] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([AssignmentStudyPlan].self, from: data)
    }
    
    func save(_ plans: [AssignmentStudyPlan]) throws {
        let data = try JSONEncoder().encode(plans)
        try data.write(to: fileURL, options: .atomic)
    }
}
