//
//  ChallengesViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    func loadChallenges() {
        print("Start fetching challenges...")
        
        db.collection("challenges").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching challenges: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No challenges found")
                DispatchQueue.main.async {
                    self?.challenges = []
                }
                return
            }
            
            print("Fetched \(documents.count) documents")
            
            DispatchQueue.global(qos: .userInitiated).async {
                var fetchedChallenges = [Challenge]()
                
                for document in documents {
                    do {
                        let data = document.data()
                        print("Document data: \(data)")
                        var challenge = try document.data(as: Challenge.self)
                        challenge.id = document.documentID // Ensure the challenge has a unique ID
                        fetchedChallenges.append(challenge)
                    } catch {
                        print("Error decoding challenge: \(error.localizedDescription)")
                    }
                }
                
                print("Fetched Challenges Before Filtering Duplicates:")
                fetchedChallenges.forEach { print($0) }
                
                // Filter duplicates by ensuring each challenge has a unique id
                let uniqueChallenges = Array(
                    Dictionary(
                        uniqueKeysWithValues: fetchedChallenges.map { ($0.id ?? UUID().uuidString, $0) }
                    ).values
                )
                
                print("Challenges After Filtering Duplicates:")
                uniqueChallenges.forEach { print($0) }
                
                DispatchQueue.main.async {
                    self?.challenges = uniqueChallenges
                    print("Challenges updated in UI")
                }
            }
        }
    }



    // Rest of the functions...




    func startChallenge(_ challenge: Challenge) {
        var mutableChallenge = challenge
        mutableChallenge.startDate = Timestamp(date: Date())

        if challenge.title.contains("Walk 10,000+ Steps") || challenge.title.contains("Walk 15,000+ Steps") {
            mutableChallenge.endDate = Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        } else if challenge.title.contains("Walk 20,000+ Steps") {
            mutableChallenge.endDate = Timestamp(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
        } else {
            mutableChallenge.endDate = nil
        }

        mutableChallenge.dailyStepCounts.removeAll()
        mutableChallenge.isCompleted = false
        mutableChallenge.goldMedalsCount = 0 // Reset gold medals count

        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = mutableChallenge
            saveChallenge(challenges[index])
        }

        if mutableChallenge.endDate != nil {
            Timer.publish(every: 86400, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.fetchDailySteps(for: mutableChallenge)
                }
                .store(in: &cancellables)
        }
    }

    func fetchDailySteps(for challenge: Challenge) {
        guard let startDate = challenge.startDate?.dateValue(), let endDate = challenge.endDate?.dateValue() else { return }

        let today = Calendar.current.startOfDay(for: Date())
        guard today <= endDate else { return }

        let stepsToday = Int.random(in: 0...15000) // Replace with actual steps data
        recordDailySteps(for: challenge, date: today, steps: stepsToday)
    }

    func updateProgress(for challenge: Challenge, progress: Double) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].progress = progress
            if progress >= 1.0 {
                challenges[index].isCompleted = true
                saveChallenge(challenges[index])
                awardBadge(for: challenges[index])
            }
        }
    }

    func recordDailySteps(for challenge: Challenge, date: Date, steps: Int) {
        guard let index = challenges.firstIndex(where: { $0.id == challenge.id }) else { return }

        if let startDate = challenges[index].startDate?.dateValue(), let endDate = challenges[index].endDate?.dateValue() {
            if date >= startDate && date <= endDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                let dateString = dateFormatter.string(from: date)
                challenges[index].dailyStepCounts[dateString] = steps
                saveChallenge(challenges[index])

                let daysMetGoal = challenges[index].dailyStepCounts.values.filter { $0 >= 10000 }.count
                let progress = Double(daysMetGoal) / 7.0

                updateProgress(for: challenges[index], progress: progress)
            }
        }
    }

    func awardBadge(for challenge: Challenge) {
        // Implement badge awarding logic here
        print("Badge awarded for completing \(challenge.title)!")
    }

    func restartChallenge(_ challenge: Challenge) {
        startChallenge(challenge)
    }

    func saveChallenge(_ challenge: Challenge) {
        do {
            guard let id = challenge.id else {
                print("Challenge ID is nil")
                return
            }

            let challengeRef = db.collection("challenges").document(id)
            try challengeRef.setData(from: challenge)
        } catch {
            print("Error saving challenge: \(error.localizedDescription)")
        }
    }

    func updateLeaderboardGoldMedal(for userId: String) {
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)

        // Assuming you have a function to get today's leaderboard winner
        if isGoldMedalWinner(userId) {
            for (index, challenge) in challenges.enumerated() {
                if challenge.title == "Get Gold Medal 3 Times" && challenge.goldMedalsCount < 3 {
                    challenges[index].goldMedalsCount += 1
                    if challenges[index].goldMedalsCount >= 3 {
                        challenges[index].isCompleted = true
                    }
                    updateProgress(for: challenges[index], progress: Double(challenges[index].goldMedalsCount) / 3.0)
                    saveChallenge(challenges[index])
                }
            }
        }
    }

    func isGoldMedalWinner(_ userId: String) -> Bool {
        // Implement logic to check if the user is the gold medal winner
        // For example, compare userId with the winner of today's leaderboard
        // This is a placeholder logic and should be replaced with actual implementation
        return true // This should be replaced with actual logic
    }

    func updateLeaderboard() {
        // Assuming you have a way to get the userId of the gold medal winner
        let goldMedalWinnerUserId = getGoldMedalWinnerUserId()
        updateLeaderboardGoldMedal(for: goldMedalWinnerUserId)
    }

    func getGoldMedalWinnerUserId() -> String {
        // Implement logic to get the userId of the gold medal winner
        // This is a placeholder logic and should be replaced with actual implementation
        return "someUserId" // Replace with actual logic
    }
}
