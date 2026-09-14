//
//  StudyPlanListView.swift
//  StudyPlanner
//
//  Created by Yufan on 13/9/2026.
//

import SwiftUI

struct StudyPlanListView: View {
    @ObservedObject var viewModel: StudyPlannerViewModel
    
    var body: some View {
        List {
            if let message = viewModel.storageError {
                Section("Storage Issue") {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
            
            if viewModel.plans.isEmpty {
                if viewModel.storageError == nil {
                    ContentUnavailableView(
                        "No Study Plan",
                        systemImage: "calendar",
                        description: Text("Tap '+' to create and approve a study plan.")
                    )
                }
            } else {
                ForEach(viewModel.plans.sorted {
                    $0.assignment.dueDate < $1.assignment.dueDate
                }) { plan in
                    NavigationLink(value: StudyPlannerRoute.details(plan.id)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plan.assignment.title)
                                .font(.headline)
                            
                            Text(plan.assignment.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(
                                plan.assignment.dueDate,
                                format: .dateTime.day().month().hour().minute()
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            ProgressView(value: plan.progress) {
                                Text("Study progress")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Study Plans")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: StudyPlannerRoute.newAssignment) {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StudyPlanListView(viewModel: StudyPlannerViewModel())
    }
}
