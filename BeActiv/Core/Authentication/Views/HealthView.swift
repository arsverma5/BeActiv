//
//  HealthView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

//
//  HealthView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

struct HealthView: View {
    @StateObject private var healthStore = HealthStore()
    @EnvironmentObject var viewModel: AuthViewModel

    private var sortedSteps: [Step] {
        healthStore.steps.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    var body: some View {
        VStack {
            Text("Your Steps Over the Past 14 Days")
                .font(.headline)
                .padding(.top)
            if sortedSteps.isEmpty {
                Text("No step data available")
            } else {
                List(sortedSteps, id: \.date) { step in
                    HStack {
                        Circle()
                            .fill(step.count >= 10000 ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(step.date, style: .date)
                        Spacer()
                        Text("\(step.count) steps")
                        if step.date == sortedSteps.first?.date {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await healthStore.requestAuthorization()
                    try await healthStore.fetchSteps(forDays: 14)
                } catch {
                    print(error)
                }
            }
        }
        .padding()
        .navigationTitle("BeActiv")
    }
}

#Preview {
    NavigationStack {
        HealthView()
    }
}


