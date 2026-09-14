//
//  StudyPlannerViewModel.swift
//  StudyPlanner
//
//  Created by Yufan on 10/9/2026.
//

import Foundation
import Combine

enum StudyPlannerRoute: Hashable {
    case newAssignment
    case review
    case approved(UUID)
    case details(UUID)
}

@MainActor
class StudyPlannerViewModel: ObservableObject {
    @Published var draftPlan: AssignmentStudyPlan?
    @Published var generationError: StudyPlanGenerationError?
    @Published var approvalError: StudyPlanApprovalError?
    @Published private(set) var plans: [AssignmentStudyPlan] = []
    @Published var storageError: String?
    @Published var completionError: String?
    @Published var navigationPath: [StudyPlannerRoute] = []
    @Published var rescheduleError: String?
    @Published var deletionError: String?
    
    private let repository: any StudyPlanRepository
    
    convenience init() {
        self.init(repository: JSONStudyPlanRepository())
    }
    
    init(repository: any StudyPlanRepository) {
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
    
    func completeSession(planID: UUID, sessionID: UUID) -> Bool {
        completionError = nil
        
        do {
            var updatedPlans = try repository.load()
            
            guard let index = updatedPlans.firstIndex(where: { $0.id == planID}) else {
                completionError = "Failed to find the plan, please try again."
                return false
            }
            
            updatedPlans[index] = try CompleteStudySessionUseCase().execute(
                plan: updatedPlans[index],
                sessionID: sessionID
            )
            
            try repository.save(updatedPlans)
            plans = updatedPlans
            storageError = nil
            return true
        } catch let error as StudySessionCompletionError {
            completionError = error.localizedDescription
            return false
        } catch {
            completionError = "Failed to save your progress. Please try again"
            return false
        }
    }
    
    func rescheduleSession(planID: UUID, sessionID: UUID, startsAt: Date) -> Bool {
        rescheduleError = nil
        
        do {
            var updatedPlans = try repository.load()
            
            guard let index = updatedPlans.firstIndex(where: { $0.id == planID }) else {
                rescheduleError = "This plan could not be found. Reopen your saved plans."
                return false
            }
            
            updatedPlans[index] = try RescheduleStudySessionUseCase().execute(
                plan: updatedPlans[index], sessionID: sessionID, startsAt: startsAt
            )
            
            try repository.save(updatedPlans)
            plans = updatedPlans
            storageError = nil
            return true
        } catch let error as StudySessionRescheduledError {
            rescheduleError = error.localizedDescription
            return false
        } catch {
            rescheduleError = "Failed to save your progress. Please try again"
            return false
        }
    }
    
    func deletePlan(planID: UUID) -> Bool {
        deletionError = nil
        
        do {
            var updatedPlans = try repository.load()
            updatedPlans.removeAll(where: { $0.id == planID })
            
            try repository.save(updatedPlans)
            plans = updatedPlans
            storageError = nil
            
            if draftPlan?.id == planID {
                draftPlan = nil
            }
            return true
        } catch {
            deletionError = "Failed to delete the plan. Please try again"
            return false
        }
    }
}
