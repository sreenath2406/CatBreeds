//
//  CatBreedFilterService.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/25/26.
//

import Foundation
import NaturalLanguage

enum CatBreedFilterError: Error {
    case modelLoadFailed
}

/// Maps classifier labels to CatBreed filtering logic.
enum CatBreedCharacteristic {
    /// Higher is better (e.g., child_friendly >= 4)
    case highRating(threshold: Int, property: (CatBreed) -> Int?)
    /// Lower is better (e.g., grooming <= 2 for low maintenance)
    case lowRating(maxValue: Int, property: (CatBreed) -> Int?)
}

final class CatBreedFilterService {
    private let nlModel: NLModel
    private let minConfidence: Double

    init(minConfidence: Double = 0.60) throws {
        let mlModel = try CatQueryClassifier(configuration: .init()).model
        self.nlModel = try NLModel(mlModel: mlModel)
        self.minConfidence = minConfidence
    }

    /// Returns the classified label if confidence >= threshold, otherwise nil.
    func classify(query: String) -> String? {
        let normalized = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // Avoid classifying extremely short queries like "d" or "do"
        guard !normalized.isEmpty, normalized.count >= 2 else { return nil }

        let hypotheses = nlModel.predictedLabelHypotheses(for: normalized, maximumCount: 3)
        let sorted = hypotheses.sorted { $0.value > $1.value }

        guard let best = sorted.first else {
            print("[Classifier] query=\"\(normalized)\" → no hypothesis")
            return nil
        }

        let label = best.key
        let confidence = best.value
        let passed = confidence >= minConfidence

        let hypothesesDescription = sorted
            .map { "\($0.key)=\(String(format: "%.3f", $0.value))" }
            .joined(separator: ", ")
        return passed ? label : nil
    }

    /// Filters breeds by the given classifier label.
    /// - Parameters:
    ///   - breeds: Source breeds to filter
    ///   - label: Classifier output (e.g. "child_friendly", "dog_friendly", "grooming")
    /// - Returns: Filtered breeds matching the characteristic
    func filter(breeds: [CatBreed], byLabel label: String) -> [CatBreed] {
        guard let characteristic = characteristic(for: label) else {
            print("[Filter] label=\(label) → unknown, returning all \(breeds.count) breeds")
            return breeds
        }

        switch characteristic {
        case .highRating(let threshold, let property):
            // Filter to breeds that meet the threshold, then sort by rating (highest first).
            var result = breeds.filter { breed in
                guard let value = property(breed) else { return false }
                return value >= threshold
            }
            result.sort { lhs, rhs in
                let l = property(lhs) ?? Int.min
                let r = property(rhs) ?? Int.min
                return l > r
            }
            print("[Filter] label=\(label) threshold>=\(threshold) → \(result.count)/\(breeds.count) breeds (sorted desc)")
            return result

        case .lowRating(let maxValue, let property):
            // Filter to breeds at or below the max, then sort by rating (lowest first).
            var result = breeds.filter { breed in
                guard let value = property(breed) else { return false }
                return value <= maxValue
            }
            result.sort { lhs, rhs in
                let l = property(lhs) ?? Int.max
                let r = property(rhs) ?? Int.max
                return l < r
            }
            print("[Filter] label=\(label) max<=\(maxValue) → \(result.count)/\(breeds.count) breeds (sorted asc)")
            return result
        }
    }

    private func characteristic(for label: String) -> CatBreedCharacteristic? {
        switch label {
            case "child_friendly":
                return .highRating(threshold: 4, property: { $0.childFriendly })
            case "dog_friendly":
                return .highRating(threshold: 4, property: { $0.dogFriendly })
            case "grooming":
                // Low maintenance = low grooming score
                return .lowRating(maxValue: 2, property: { $0.grooming })
            default:
                return nil
        }
    }
}
