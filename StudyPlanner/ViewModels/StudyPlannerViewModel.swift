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
    @Published var approvalError: StudyPlanApprovalError?
    @Published private(set) var plans: [AssignmentStudyPlan] = []
    @Published var storageError: String?
    
    private let repository: any StudyPlanRepository
    
    init(
        repository: any StudyPlanRepository = JSONStudyPlanRepository()
    ) {
        self.repository = repository
        
        do {
            plans = try repository.load()
        } catch {
            storageError = "Saved plans could not be loaded. Your saved files has not been changed"
        }
    }
    
    
    
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
    
    func approvePlan(
        _ plan: AssignmentStudyPlan
    ) -> AssignmentStudyPlan? {
        approvalError = nil
        storageError = nil
        
        do {
            let approved = try ApproveStudyPlanUseCase().execute(plan: plan)
            
            var updatedPlans = try repository.load()
            
            if let index = updatedPlans.firstIndex(where: { $0.id == approved.id }) {
                updatedPlans[index] = approved
            } else {
                updatedPlans.append(approved)
            }
            
            try repository.save(updatedPlans)
            plans = updatedPlans
            return approved
        } catch let error as StudyPlanApprovalError {
            approvalError = error
            return nil
        } catch {
            storageError = "Failed to save your plan. Please try again"
            return nil
        }
    }
}
