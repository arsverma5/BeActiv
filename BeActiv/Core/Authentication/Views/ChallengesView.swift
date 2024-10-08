//
//  ChallengesView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//
import SwiftUI
import FirebaseFirestoreSwift

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.challenges.isEmpty {
                    Text("No challenges available")
                } else {
                    ForEach(viewModel.challenges) { challenge in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(challenge.icon)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(challenge.title)
                                        .font(.headline)
                                    Text(challenge.description)
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            
                            ProgressView(value: challenge.progress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: challenge)))
                                .padding(.top, 8)
                            
                            if challenge.isCompleted {
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundColor(Color.green)
                            } else {
                                if let startDate = challenge.startDate, let endDate = challenge.endDate {
                                    Text("Started on \(startDate.dateValue().formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                    Text("Ends on \(endDate.dateValue().formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                }
                                Button(action: {
                                    viewModel.startChallenge(challenge)
                                }) {
                                    Text("Start Challenge")
                                        .foregroundColor(.blue)
                                        .padding(.top, 8)
                                }
                                Button(action: {
                                    viewModel.restartChallenge(challenge)
                                }) {
                                    Text("Restart Challenge")
                                        .foregroundColor(.red)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding()
                        .background(challenge.startDate != nil ? Color.yellow.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Challenges")
        }
        .onAppear {
            viewModel.loadChallenges()
        }
    }
    
    private func progressColor(for challenge: Challenge) -> Color {
        switch challenge.title {
        case "Walk 10,000+ Steps":
            return Color.green
        case "Beat 5 Friends":
            return Color.purple
        default:
            return Color.blue
        }
    }
}
