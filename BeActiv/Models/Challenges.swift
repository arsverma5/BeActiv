//
//  Challenges.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Challenge: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let icon: String
    var progress: Double
    var isCompleted: Bool
    var startDate: Timestamp?
    var endDate: Timestamp?
    var dailyStepCounts: [String: Int]
    var goldMedalsCount: Int

    init(
        id: String? = nil,
        title: String,
        description: String,
        icon: String,
        progress: Double = 0.0,
        isCompleted: Bool = false,
        startDate: Timestamp? = nil,
        endDate: Timestamp? = nil,
        dailyStepCounts: [String: Int] = [:],
        goldMedalsCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.progress = progress
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
        self.dailyStepCounts = dailyStepCounts
        self.goldMedalsCount = goldMedalsCount
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case icon
        case progress
        case isCompleted
        case startDate
        case endDate
        case dailyStepCounts
        case goldMedalsCount
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Challenge, rhs: Challenge) -> Bool {
        return lhs.id == rhs.id
    }

    // Custom decoder with detailed logging
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.id = try container.decodeIfPresent(String.self, forKey: .id)
            self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Unknown Title"
            self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? "No Description"
            self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
            self.progress = try container.decodeIfPresent(Double.self, forKey: .progress) ?? 0.0
            self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
            self.startDate = try container.decodeIfPresent(Timestamp.self, forKey: .startDate)
            self.endDate = try container.decodeIfPresent(Timestamp.self, forKey: .endDate)
            self.dailyStepCounts = try container.decodeIfPresent([String: Int].self, forKey: .dailyStepCounts) ?? [:]
            self.goldMedalsCount = try container.decodeIfPresent(Int.self, forKey: .goldMedalsCount) ?? 0
        } catch {
            print("Error decoding challenge: \(error.localizedDescription)")
            print("Decoding failure for document: \(container)")
            throw error
        }
    }
}
