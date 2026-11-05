//
//  workout_tracker_appTests.swift
//  workout-tracker-appTests
//
//  Created by Ole Thomas Skogli on 05/11/2026.
//

import Foundation
import SwiftData
import Testing

@testable import workout_tracker_app

// MARK: - Test helpers

/// An in-memory SwiftData database for a single test.
/// Owning the container here keeps it alive for the whole test.
@MainActor
struct TestDatabase {
    let container: ModelContainer
    var context: ModelContext { container.mainContext }

    init() throws {
        container = try ModelContainer(
            for: Workout.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}

@MainActor
@Suite("Exercise")
struct ExerciseTests {
    let database: TestDatabase

    init() throws {
        database = try TestDatabase()
    }

    /// Creates an exercise with the given sets and inserts it into the test database.
    private func makeExercise(type: ExerciseType = .weighted, sets: [WorkoutSet]) -> Exercise {
        let exercise = Exercise(name: "Test", type: type, sets: sets)
        database.context.insert(exercise)
        return exercise
    }

    @Test func totalVolumeAssUpAllSets() {
        let exercise = Exercise(
            name: "Bench press",
            sets: [
                WorkoutSet(reps: 8, weight: 60),
                WorkoutSet(reps: 8, weight: 62.5),
            ]
        )
        #expect(exercise.totalVolume == 980)
    }

    @Test("Best weight and reps in a set")
    func bestWeightsAndRepsInSet() throws {
        let exercise = makeExercise(sets: [
            WorkoutSet(reps: 8, weight: 20),
            WorkoutSet(reps: 12, weight: 40),
            WorkoutSet(reps: 12, weight: 60),
        ])

        let best = try #require(exercise.bestSet)
        #expect(best.weight == 60)
        #expect(best.reps == 12)
    }

}

@MainActor
@Suite("Workout stats")
struct WorkoutStatsTests {
    let database: TestDatabase
    let calendar: Calendar

    let now: Date

    init() throws {
        database = try TestDatabase()

        // Fixed calendar: weeks start on Monday in UTC on every machine
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        calendar.firstWeekday = 2
        self.calendar = calendar

        now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 5, hour: 12)))
    }

    /// A date at noon on the given day.
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
            ?? .distantPast
    }

    /// Inserts a workout with one set of 10 × 100 kg (1 000 kg volume).
    private func addWorkout(on date: Date) -> Workout {
        let workout = Workout(
            name: "Test",
            date: date,
            exercises: [Exercise(name: "Squat", sets: [WorkoutSet(reps: 10, weight: 100)])]
        )
        database.context.insert(workout)
        return workout
    }

    @Test("Current week has 7 days, marks trained days and future days")
    func currentWeekDaysMarksTrainedAndFutureDays() async throws {
        let wednesday = date(2026, 11, 4)
        let workouts = [addWorkout(on: wednesday)]

        let days = WorkoutStats.currentWeekDays(for: workouts, now: now, calendar: calendar)

        #expect(days.count == 7)

        let wednesdayActivity = try #require(
            days.first { calendar.isDate($0.day, inSameDayAs: wednesday) }
        )
        #expect(wednesdayActivity.trained)
    }
}

@MainActor
@Suite("Workout")
struct WorkoutTests {
    let database: TestDatabase

    init() throws {
        database = try TestDatabase()
    }

    @Test("Deleting a workout also deletes its exercises and sets")
    func deletingWorkoutDeletesExercisesAndSets() throws {
        let workout = Workout(
            name: "Legs",
            date: .now,
            exercises: [Exercise(name: "Squat", sets: [WorkoutSet(reps: 5, weight: 100)])]
        )
        database.context.insert(workout)
        try database.context.save()

        #expect(try database.context.fetchCount(FetchDescriptor<Exercise>()) == 1)

        // Test delete:
        database.context.delete(workout)
        try database.context.save()

        // Assert: its exercises and sets are gone too
        #expect(try database.context.fetchCount(FetchDescriptor<Exercise>()) == 0)
        #expect(try database.context.fetchCount(FetchDescriptor<WorkoutSet>()) == 0)
    }
}
