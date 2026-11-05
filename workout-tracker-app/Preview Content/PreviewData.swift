//
//  PreviewData.swift
//  workout-tracker-app
//
//  Sample data used only by #Preview blocks. Never touches the real database.
//

import Foundation
import SwiftData

extension Workout {
    /// Sample workouts spread over ~5 weeks, with one week skipped to show a gap.
    static func previewSamples() -> [Workout] {
        [
            previewWorkout("Legs", daysAgo: 0, weight: 110),
            previewWorkout("Full body", daysAgo: 1, weight: 105),
            previewWorkout("Legs", daysAgo: 7, weight: 105),
            previewWorkout("Full body", daysAgo: 9, weight: 100),
            previewWorkout("Legs", daysAgo: 14, weight: 100),
            previewWorkout("Legs", daysAgo: 28, weight: 95),
            previewWorkout("Full body", daysAgo: 35, weight: 90),
        ]
    }

    /// Creates a sample squat workout a number of days before today.
    private static func previewWorkout(_ name: String, daysAgo: Int, weight: Double) -> Workout {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        return Workout(
            name: name,
            date: date,
            exercises: [
                Exercise(
                    name: "Squat",
                    sets: [
                        WorkoutSet(reps: 5, weight: weight),
                        WorkoutSet(reps: 5, weight: weight),
                        WorkoutSet(reps: 5, weight: weight),
                    ]
                )
            ]
        )
    }
}

extension ModelContainer {
    /// An in-memory container filled with `Workout.previewSamples()`, for views that use `@Query`.
    @MainActor
    static var preview: ModelContainer {
        do {
            let container = try ModelContainer(
                for: Workout.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            for workout in Workout.previewSamples() {
                container.mainContext.insert(workout)
            }
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
