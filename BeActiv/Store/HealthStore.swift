//
//  HealthStore.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/27/24.
//

import HealthKit
import Foundation

class HealthStore: ObservableObject {
    @Published var steps: [Step] = []
    private var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization() async throws {
        guard let healthStore = healthStore else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        try await healthStore.requestAuthorization(toShare: [], read: [stepType])
    }

    func fetchSteps(forDays days: Int) async throws {
        guard let healthStore = healthStore else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var stepsArray: [Step] = []

        for dayOffset in 0..<days {
            let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -dayOffset, to: now)!)
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    return
                }
                let stepCount = sum.doubleValue(for: HKUnit.count())
                let step = Step(date: startDate, count: Int(stepCount))

                DispatchQueue.main.async {
                    stepsArray.append(step)
                    if stepsArray.count == days {
                        self.steps = stepsArray.sorted { $0.date > $1.date }
                    }
                }
            }

            healthStore.execute(query)
        }
    }
}
