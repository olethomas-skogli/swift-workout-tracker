//
//  ExerciseProgressView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import Charts
import SwiftData
import SwiftUI

struct ProgressPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ExerciseProgressView: View {
    let exercise: Exercise

    @Query(sort: \Workout.date) private var workouts: [Workout]

    private var points: [ProgressPoint] {
        workouts.compactMap { workout in
            guard
                let match = workout.exercises.first(where: {
                    $0.name.lowercased() == exercise.name.lowercased() && $0.type == exercise.type
                }),
                let best = match.bestSet
            else {
                return nil
            }
            let value = exercise.type == .weighted ? best.weight : Double(best.reps)
            return ProgressPoint(date: workout.date, value: value)
        }
    }

    private var unit: String {
        exercise.type == .weighted ? "kg" : "reps"
    }

    private var personalRecord: Double? {
        points.map(\.value).max()
    }

    private var change: Double? {
        guard points.count > 1,
            let first = points.first,
            let last = points.last
        else {
            return nil
        }
        return last.value - first.value
    }

    var body: some View {
        List {
            Section("Best set per workout") {
                if points.isEmpty {
                    ContentUnavailableView(
                        "No data yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log some sets to see your progress.")
                    )
                } else {
                    Chart(points) { point in
                        LineMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value(unit, point.value)
                        )
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value(unit, point.value)
                        )
                    }
                    .chartYAxisLabel(unit)
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 240)
                    .padding(.vertical)
                }
            }
            if !points.isEmpty {
                Section("Stats") {
                    LabeledContent("Workouts logged", value: "\(points.count)")
                    if let personalRecord {
                        LabeledContent(
                            "Personal record", value: "\(personalRecord.formatted()) \(unit)")
                    }
                    if let change {
                        LabeledContent(
                            "Change since first",
                            value: "\(change.formatted(.number.sign(strategy: .always()))) \(unit)"
                        )
                    }
                }
            }

        }
        .navigationTitle(exercise.name)
    }
}
