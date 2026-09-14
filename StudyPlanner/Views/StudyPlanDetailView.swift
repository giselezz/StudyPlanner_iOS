//
//  StudyPlanDetailView.swift
//  StudyPlanner
//
//  Created by Yufan on 14/9/2026.
//

import SwiftUI

struct StudyPlanDetailView: View {
    @ObservedObject var viewModel: StudyPlannerViewModel
    let planID: UUID
    @State private var showCompletionError = false
    
    var body: some View {
        Group {
            if let plan = viewModel.plans.first(where: { $0.id == planID }) {
                Form {
                    Section("Assignment") {
                        Text(plan.assignment.title).font(.headline)
                        
                        LabeledContent("Due Date") {
                            Text(plan.assignment.dueDate, format: .dateTime.day().month().hour().minute())
                        }
                    }
                    ForEach(plan.sessions) { session in
                        Section(session.taskTitle) {
                            if let start = session.startsAt {
                                LabeledContent("Start") {
                                    Text(start, format: .dateTime.day().month().hour().minute())
                                }
                            }
                                
                            if let minutes = session.durationMinutes {
                                LabeledContent("Duration", value: "\(minutes) minutes")
                            }
                                
                            if session.isCompleted {
                                Label("Completed", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Button("Mark as Completed") {
                                    showCompletionError = !viewModel.completeSession(planID: planID, sessionID: session.id)
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.blue)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Plan not found",
                    systemImage: "calendar",
                    description: Text("Go back to saved plans.")
                )
            }
        }
        .navigationTitle("Plan Details")
        .alert("Unable to save Progress", isPresented: $showCompletionError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                viewModel.completionError ?? "An unknown error occurred. Please try again."
            )
        }
    }
}


#Preview {
    ContentView()
}
