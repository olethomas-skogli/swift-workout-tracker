//
//  WorkoutStats.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import Foundation

struct WeekVolume: Identifiable {
    let weekStart: Date
    let volume: Double

    var id: Date { weekStart }
}

struct DayActivity: Identifiable {
    let day: Date
    let trained: Bool
    let isFuture: Bool

    var id: Date { day }
}

enum WorkoutStats {
    /// Total volume per week, from the week of the first workout up to this week,
    /// showing at most `maxWeeks` weeks. Weeks in between without workouts are 0.
    static func weeklyVolume(
        for workouts: [Workout],
        maxWeeks: Int = 8,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [WeekVolume] {
        let pastWorkouts = workouts.filter { $0.date <= now }

        guard
            let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
            let firstDate = pastWorkouts.map(\.date).min(),
            let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: firstDate)?.start
        else {
            return []
        }

        // How many weeks from the first workout's week to this week (inclusive), capped
        let weeksSinceFirst =
            calendar.dateComponents(
                [.weekOfYear], from: firstWeekStart, to: thisWeekStart
            ).weekOfYear ?? 0
        let weekCount = min(weeksSinceFirst + 1, maxWeeks)

        let volumeByWeek = Dictionary(grouping: pastWorkouts) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.date)?.start ?? workout.date
        }
        .mapValues { workoutsInWeek in
            workoutsInWeek.reduce(0) { total, workout in total + workout.totalVolume }
        }

        return (0..<weekCount).reversed().compactMap { offset in
            guard
                let weekStart = calendar.date(
                    byAdding: .weekOfYear, value: -offset, to: thisWeekStart)
            else {
                return nil
            }
            return WeekVolume(weekStart: weekStart, volume: volumeByWeek[weekStart] ?? 0)
        }
    }
    /// Consecutive weeks with at least one workout.
    /// The current week only adds to the streak; it doesn't break it until it's over.
    static func weekStreak(
        for workouts: [Workout],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let trainedWeeks = Set(
            workouts
                .filter { $0.date <= now }
                .compactMap { calendar.dateInterval(of: .weekOfYear, for: $0.date)?.start }
        )
        guard var week = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return 0
        }

        // No workout yet this week? Start counting from last week instead.
        if !trainedWeeks.contains(week) {
            guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: week) else {
                return 0
            }
            week = lastWeek
        }

        var streak = 0
        while trainedWeeks.contains(week) {
            streak += 1
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: week) else {
                break
            }
            week = previous
        }
        return streak
    }
    /// The 7 days of the current week, and whether you trained on each one.
    static func currentWeekDays(
        for workouts: [Workout],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [DayActivity] {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }

        let today = calendar.startOfDay(for: now)
        let trainedDays = Set(workouts.map { calendar.startOfDay(for: $0.date) })

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            return DayActivity(
                day: day,
                trained: trainedDays.contains(day),
                isFuture: day > today
            )
        }
    }
}
