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
    @State private var editingSessionID: UUID?
    @State private var newStart = Date()
    @State private var showRescheduleError = false
    @State private var showDeleteConfirmation = false
    @State private var didDeletePlan = false
    
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
                            } else if editingSessionID == session.id {
                                DatePicker("New Start Time", selection: $newStart, displayedComponents: [.date, .hourAndMinute]
                                )
                                
                                Text("The duration stays unchanged. You new time is saved only when you tap Save.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Button("Cancel", role: .cancel) {
                                        editingSessionID = nil
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Spacer()
                                    
                                    Button("Save") {
                                        if viewModel.rescheduleSession(planID: plan.id, sessionID: session.id, startsAt: newStart) {
                                            editingSessionID = nil
                                        } else {
                                            showRescheduleError = true
                                        }
                                    }
                                    .buttonStyle(.glassProminent)
                                    .tint(.blue)
                                }
                            } else {
                                Button("Mark as Completed") {
                                    showCompletionError = !viewModel.completeSession(planID: plan.id, sessionID: session.id)
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.blue)
                                .disabled(editingSessionID != nil)
                                
                                Button("Reschedule") {
                                    newStart = max (session.startsAt ?? Date(), Date().addingTimeInterval(3600))
                                    editingSessionID = session.id
                                }
                                .buttonStyle(.bordered)
                                .disabled(editingSessionID != nil)
                            }
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Plan", systemImage: "trash")
                        }
                        .disabled(editingSessionID != nil)
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
        .alert("Unable to reschedule", isPresented: $showRescheduleError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                viewModel.rescheduleError ?? "An unknown error occurred. Please try again."
            )
        }
        
        .sheet(isPresented: $showDeleteConfirmation, onDismiss: {
            if didDeletePlan {
                didDeletePlan = false
                viewModel.navigationPath.removeAll()
            }
        }) {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)

                    Text("Delete this plan?")
                        .font(.title2.bold())

                    Text("This permanently deletes the plan, its sessions and its progress from this device. This cannot be undone.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if let message = viewModel.deletionError {
                        Text(message)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button("Cancel", role: .cancel) {
                        showDeleteConfirmation = false
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)

                    Button(role: .destructive) {
                        if viewModel.deletePlan(planID: planID) {
                            didDeletePlan = true
                            showDeleteConfirmation = false
                        }
                    } label: {
                        Text("Delete Plan")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .controlSize(.large)
                }
                .padding(24)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .onAppear {
                viewModel.deletionError = nil
            }
        }
    }
}


#Preview {
    ContentView()
}
