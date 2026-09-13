//
//  StudyPlanReviewView.swift
//  StudyPlanner
//
//  Created by Yufan on 11/9/2026.
//

import SwiftUI

struct StudyPlanReviewView: View {
    @Binding var plan: AssignmentStudyPlan
    @FocusState private var isDurationFocused: Bool
    @ObservedObject var viewModel: StudyPlannerViewModel
    @State private var showApprovalError = false
    
    var body: some View {
        Form {
            Section("Assignment") {
                Text(plan.assignment.title)
                    .font(.headline)
                
                LabeledContent("Submission Deadline") {
                    Text(plan.assignment.dueDate, format: .dateTime
                        .day().month().hour().minute())
                }
            }
            
            ForEach($plan.sessions) { $session in
                Section(session.taskTitle) {
                    HStack {
                        Text("Duration (Minutes)")
                        
                        TextField(
                            "Required",
                            value: $session.durationMinutes,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .focused($isDurationFocused)
                    }
                    
                    if session.startsAt != nil {
                        DatePicker(
                            "Start Time", selection: Binding(get: { session.startsAt ?? Date() }, set: { session.startsAt = $0} ),
                            displayedComponents: [.date, .hourAndMinute])
                    } else {
                        Button("Set Study Time") {session.startsAt = Date().addingTimeInterval(3600)
                        }
                    }
                    
                    Text("Suggest duration. Choose a start time that suits your availability.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(plan.isApproved)
            
            Section {
                if plan.isApproved {
                    Label("Plan Approved", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                    Text("Your plan is approved and saved.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Review your plan and approve it to save it to your study planner.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Plan Your Study")
        .alert("Unable to Approve Plan", isPresented: $showApprovalError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.storageError ?? viewModel.approvalError?.localizedDescription ?? "Please review your study times and try again.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Approve") {
                    isDurationFocused = false
                    
                    if let approved = viewModel.approvePlan(plan) {
                        plan = approved
                    } else {
                        showApprovalError = true
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
                .disabled(plan.isApproved)
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button {
                    isDurationFocused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .accessibilityLabel(Text("Dismiss Keyboard"))
            }
        }
    }
}

#Preview {
    @Previewable @State var plan = AssignmentStudyPlan(
        assignment: UniversityAssignment(
            title: "History Essay",
            type: .essay,
            dueDate: Date().addingTimeInterval(604800)
        ),
        sessions: [
            StudySession(taskTitle: "Research"),
            StudySession(taskTitle: "Outline"),
            StudySession(taskTitle: "Draft"),
            StudySession(taskTitle: "Edit")
        ]
    )
    
    NavigationStack {
        StudyPlanReviewView(plan: $plan, viewModel: StudyPlannerViewModel())
    }
}
