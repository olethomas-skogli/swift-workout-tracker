//
//  Workout.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 03/11/2026.
//

import Foundation
import SwiftData

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case weighted
    case bodyweight

    var id: Self { self }

    var label: String {
        switch self {
        case .weighted: "Weight & reps"
        case .bodyweight: "Bodyweight"
        }
    }
}

@Model
final class WorkoutSet {
    var reps: Int
    var weight: Double  // kg
    var createdAt = Date.now

    init(reps: Int, weight: Double) {
        self.reps = reps
        self.weight = weight
    }

    var volume: Double {
        Double(reps) * weight
    }
}

@Model
final class Exercise {
    var name: String
    var type: ExerciseType = ExerciseType.weighted
    var createdAt = Date.now
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]

    init(name: String, type: ExerciseType = .weighted, sets: [WorkoutSet]) {
        self.name = name
        self.type = type
        self.sets = sets
    }

    var totalVolume: Double {
        sets.reduce(0) { total, set in total + set.volume }
    }

    var totalSets: Int {
        sets.count
    }

    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.createdAt < $1.createdAt }
    }

    var totalReps: Int {
        sets.reduce(0) { total, set in total + set.reps }
    }

    var summary: String {
        guard totalSets > 0 else { return "No sets yet" }

        let setsText = totalSets == 1 ? "1 set" : "\(totalSets) sets"
        switch type {
        case .weighted:
            return "\(setsText) · \(totalVolume.formatted()) kg"
        case .bodyweight:
            return "\(setsText) · \(totalReps) reps"
        }
    }

    var bestSet: WorkoutSet? {
        sets.max { a, b in
            switch type {
            case .weighted:
                if a.weight == b.weight {
                    return a.reps < b.reps
                }
                return a.weight < b.weight
            case .bodyweight:
                return a.reps < b.reps
            }
        }
    }

    var bestSetLabel: String? {
        guard let best = bestSet else { return nil }

        switch type {
        case .weighted:
            return "Best: \(best.weight.formatted()) kg × \(best.reps)"
        case .bodyweight:
            return "Best: \(best.reps) reps"
        }
    }
}

@Model
final class Workout {
    var name: String
    var date: Date
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]

    init(name: String, date: Date, exercises: [Exercise]) {
        self.name = name
        self.date = date
        self.exercises = exercises
    }

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.createdAt < $1.createdAt }
    }

    var totalExercises: Int {
        exercises.count
    }

    var summary: String {
        switch totalExercises {
        case 0:
            "No exercises"
        case 1:
            "1 exercise"
        default:
            "\(totalExercises) exercises"
        }
    }

    var totalVolume: Double {
        exercises.reduce(0) { total, exercise in total + exercise.totalVolume }
    }

}
