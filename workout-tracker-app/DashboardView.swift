//
//  DashboardView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import Charts
import SwiftUI

struct DashboardView: View {
    let workouts: [Workout]

    private var workoutsThisWeek: Int {
        workouts.filter {
            Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear)
        }
        .count
    }

    var body: some View {
        let weeks = WorkoutStats.weeklyVolume(for: workouts)
        let thisWeek = weeks.last
        let streak = WorkoutStats.weekStreak(for: workouts)
        let days = WorkoutStats.currentWeekDays(for: workouts)

        VStack(alignment: .leading, spacing: 16) {
            StreakView(streak: streak, days: days)
            HStack(spacing: 12) {
                StatTile(label: "Workouts this week", value: "\(workoutsThisWeek)")
                StatTile(
                    label: "Volume this week",
                    value: "\((thisWeek?.volume ?? 0).formatted(.number.notation(.compactName))) kg"
                )
            }

            Chart(weeks) { week in
                BarMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Volume", week.volume),
                    width: .fixed(28)
                )
                .cornerRadius(4)
                .foregroundStyle(
                    week.id == thisWeek?.id ? Color.accentColor : Color.secondary.opacity(0.3))
            }
            .chartYAxisLabel("kg")
            .frame(height: 160)
        }
        .padding(.vertical, 8)
    }
}

struct StatTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}

struct StreakView: View {
    let streak: Int
    let days: [DayActivity]

    private var streakText: String {
        switch streak {
        case 0: "Start a streak this week"
        case 1: "1 week streak"
        default: "\(streak) week streak"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(streakText)
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(streak > 0 ? .orange : .secondary)
            }

            HStack {
                ForEach(days) { day in
                    VStack(spacing: 4) {
                        Text(day.day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Circle()
                            .fill(
                                day.trained
                                    ? Color.accentColor
                                    : Color.secondary.opacity(day.isFuture ? 0.08 : 0.2)
                            )
                            .frame(width: 28, height: 28)
                            .overlay {
                                if day.trained {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.black)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "\(day.day.formatted(.dateTime.weekday(.wide))), \(day.trained ? "trained" : "no workout")"
                    )
                }
            }
        }
    }
}

#Preview {
    List {
        Section {
            DashboardView(workouts: Workout.previewSamples())
        }
    }
    .preferredColorScheme(.dark)
    .fontDesign(.rounded)
}
