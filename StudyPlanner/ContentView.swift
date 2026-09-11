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
        NavigationStack {
            NewAssignmentView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
