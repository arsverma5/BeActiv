//
//  ChallengesViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadChallenges()
    }
    
    func startChallenge(_ challenge: Challenge) {
        var mutableChallenge = challenge
        
        mutableChallenge.startDate = Date()
        mutableChallenge.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        mutableChallenge.dailyStepCounts.removeAll()
        mutableChallenge.isCompleted = false
        
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = mutableChallenge
            saveChallenge(challenges[index])
        }
        
        // Schedule daily check for steps
        Timer.publish(every: 86400, on: .main, in: .common) // Every 24 hours
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchDailySteps(for: mutableChallenge)
            }
            .store(in: &cancellables)
    }
    
    func fetchDailySteps(for challenge: Challenge) {
        guard let startDate = challenge.startDate, let endDate = challenge.endDate else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        guard today <= endDate else { return }
        
        let stepsToday = Int.random(in: 0...15000) // Simulated step count for demo
        recordDailySteps(for: challenge, date: today, steps: stepsToday)
    }
    
    func updateProgress(for challenge: Challenge, progress: Double) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].progress = progress
            if progress >= 1.0 {
                challenges[index].isCompleted = true
            }
            saveChallenge(challenges[index])
        }
    }
    
    func recordDailySteps(for challenge: Challenge, date: Date, steps: Int) {
        guard let index = challenges.firstIndex(where: { $0.id == challenge.id }) else { return }
        
        if let startDate = challenges[index].startDate, let endDate = challenges[index].endDate {
            if date >= startDate && date <= endDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"  // Adjust format as per your preference
                
                let dateString = dateFormatter.string(from: date)
                challenges[index].dailyStepCounts[dateString] = steps  // Update step count for the date
                saveChallenge(challenges[index])
                
                // Check if challenge is completed
                let daysMetGoal = challenges[index].dailyStepCounts.values.filter { $0 >= 10000 }.count
                let progress = Double(daysMetGoal) / 7.0
                
                if progress >= 1.0 {
                    challenges[index].isCompleted = true
                    saveChallenge(challenges[index])
                }
            }
        }
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
    
    func loadChallenges() {
        db.collection("challenges").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error loading challenges: \(error.localizedDescription)")
                return
            }
            
            self.challenges = querySnapshot?.documents.compactMap { document -> Challenge? in
                try? document.data(as: Challenge.self)
            } ?? []
            
            // If no challenges exist, add the default challenge
            if self.challenges.isEmpty {
                let defaultChallenge = Challenge(
                    title: "Walk 10,000+ Steps for a Week",
                    description: "Achieve more than 10,000 steps each day for a whole week.",
                    icon: "🏆",
                    progress: 0.0
                )
                self.challenges.append(defaultChallenge)
                self.saveChallenge(defaultChallenge)
            }
        }
    }
}
