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
            
            Section {
                Text("This is a draft. Review each task against the assignment brief. Your plan is not approved or saved yet. ")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Plan Your Study")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isDurationFocused = false
                }
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
        StudyPlanReviewView(plan: $plan)
    }
}
