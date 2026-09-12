//
//  StudyPlannerViewModel.swift
//  StudyPlanner
//
//  Created by Yufan on 10/9/2026.
//

import Foundation
import Combine

@MainActor
class StudyPlannerViewModel: ObservableObject {
    @Published var draftPlan: AssignmentStudyPlan?
    @Published var generationError: StudyPlanGenerationError?
    
    func generatePlan(
        title: String,
        type: AssignmentType,
        dueDate: Date,
        estimatedWorkloadHours: Int
    ) {
        draftPlan = nil
        generationError = nil
        
        let assignment = UniversityAssignment(
            title: title,
            type: type,
            dueDate: dueDate,
            estimatedWorkloadHours: estimatedWorkloadHours
        )
        
        do {
            draftPlan = try GenerateStudyPlanUseCase().execute(assignment: assignment)
        } catch {
            generationError = error as? StudyPlanGenerationError
        }
    }
}
