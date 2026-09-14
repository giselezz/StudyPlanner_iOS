//
//  PlanApprovedView.swift
//  StudyPlanner
//
//  Created by Yufan on 14/9/2026.
//

import SwiftUI

struct PlanApprovedView: View {
    @ObservedObject var viewModel: StudyPlannerViewModel
    let planID: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
                
                Text("Plan Approved\nand Saved")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                if let plan = viewModel.plans.first(where: { $0.id == planID }) {
                    Text(plan.assignment.title)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    viewModel.navigationPath = [.details(planID)]
                } label: {
                    Text("View Plan Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
                .controlSize(.large)
                
                Button("Back to Home") {
                    viewModel.navigationPath.removeAll()
                }
                .buttonStyle(.glass)
                .controlSize(.large)
            }
            .padding(24)
            .padding(.top, 40)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
}
