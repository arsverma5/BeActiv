//
//  HealthView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HealthView: View {
    @StateObject private var healthStore = HealthStore()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var leaderboardsViewModel: LeaderboardsViewModel

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
                    if let todaySteps = sortedSteps.first?.count {
                        updateStepsInFirestore(steps: todaySteps)
                    }
                } catch {
                    print(error)
                }
            }
        }
        .padding()
        .navigationTitle("BeActiv")
    }

    private func updateStepsInFirestore(steps: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        userRef.updateData(["stepCount": steps]) { error in
            if let error = error {
                print("Error updating steps: \(error)")
            } else {
                print("Steps updated successfully")
                // Correctly call the method on the environment object
                leaderboardsViewModel.fetchLeaderboardData() // Use fetchLeaderboardData if that's the actual method
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthView()
            .environmentObject(AuthViewModel())
            .environmentObject(LeaderboardsViewModel())
    }
}
