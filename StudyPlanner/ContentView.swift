//
//  ContentView.swift
//  StudyPlanner
//
//  Created by Yufan on 6/9/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StudyPlannerViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            StudyPlanListView(viewModel: viewModel)
                .navigationDestination(for: StudyPlannerRoute.self) { route in
                    switch route {
                    case .newAssignment:
                        NewAssignmentView(viewModel: viewModel)
                    case .review:
                        if let draft = Binding($viewModel.draftPlan) {
                            StudyPlanReviewView(plan: draft, viewModel: viewModel)
                        }
                    case .approved(let id):
                        PlanApprovedView(viewModel: viewModel, planID: id)
                    case .details(let id):
                        StudyPlanDetailView(viewModel: viewModel, planID: id)
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
