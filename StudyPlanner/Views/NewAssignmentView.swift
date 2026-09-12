//
//  NewAssignmentView.swift
//  StudyPlanner
//
//  Created by Yufan on 10/9/2026.
//

import SwiftUI

struct NewAssignmentView: View {
    @ObservedObject var viewModel: StudyPlannerViewModel
    
    @State private var title = ""
    @State private var type: AssignmentType = .essay
    @State private var dueDate: Date = Date().addingTimeInterval(86400)
    @State private var showReview = false
    @State private var estimatedWorkloadHours = 8
    @FocusState private var isTitleFocused: Bool
    
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Assignment Title (Required)", text: $title)
                        .focused($isTitleFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isTitleFocused = false
                        }
                    
                    if viewModel.generationError == .blankTitle {
                        Label("Please enter a title for this assignment.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: title) { _, _ in
                    if viewModel.generationError == .blankTitle {
                        viewModel.generationError = nil
                    }
                }
                
                Picker("Assignment Type", selection: $type) {
                    ForEach(AssignmentType.allCases, id: \.self) {
                        type in Text(type.rawValue).tag(type)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Stepper(
                        "Total Study Time: \(estimatedWorkloadHours) hours",
                        value: $estimatedWorkloadHours,
                        in: 1...100
                    )
                    
                    Text("We'll divide this time between the suggested tasks. You can adjust each duration during review.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    DatePicker(
                        "Due Date",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    if viewModel.generationError == .deadlinePassed {
                        Label("Please choose a future submission deadline.", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: dueDate) { _, _ in
                    if viewModel.generationError == .deadlinePassed {
                        viewModel.generationError = nil
                    }
                }
                
            } header: {
                Text("Assignment Details")
            } footer: {
                Text("Generate task suggestions, then review their study dates and durations.")
            }
            
            Section {
                Button {
                    isTitleFocused = false
                    
                    viewModel.generatePlan(title: title, type: type, dueDate: dueDate, estimatedWorkloadHours: estimatedWorkloadHours)
                    
                    showReview = viewModel.draftPlan != nil
                } label: {
                    Text("Generate Study Plan")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.glassProminent)
                .tint(Color(.blue))
                .controlSize(.large)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("New Assignment")
        .navigationDestination(isPresented: $showReview) {
            if let draft = Binding($viewModel.draftPlan) {
                StudyPlanReviewView(plan: draft)
            }
        }
    }
}



#Preview {
    NavigationStack {
        NewAssignmentView(viewModel: StudyPlannerViewModel())
    }
}
