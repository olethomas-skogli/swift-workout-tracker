//
//  WorkoutDetailView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 03/11/2026.
//

import SwiftData
import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

    @Environment(\.modelContext) private var modelContext
    @State private var isAddingExercise = false
    @State private var collapsedExercises: Set<Exercise.ID> = []

    private func toggle(_ exercise: Exercise) {
        withAnimation(.snappy) {
            if collapsedExercises.contains(exercise.id) {
                collapsedExercises.remove(exercise.id)
            } else {
                collapsedExercises.insert(exercise.id)
            }
        }
    }

    var body: some View {
        List {
            ForEach(workout.sortedExercises) { exercise in
                Section {
                    Button {
                        toggle(exercise)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.headline)
                                Text(exercise.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let bestLabel = exercise.bestSetLabel {
                                    Label(bestLabel, systemImage: "trophy.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .rotationEffect(
                                    .degrees(collapsedExercises.contains(exercise.id) ? -90 : 0)
                                )
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)

                    if !collapsedExercises.contains(exercise.id) {
                        ForEach(Array(exercise.sortedSets.enumerated()), id: \.element.id) {
                            index, set in
                            SetRowView(set: set, number: index + 1, type: exercise.type)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(exercise.sortedSets[index])
                            }
                        }

                        Button("Add set", systemImage: "plus") {
                            let lastSet = exercise.sortedSets.last
                            let newSet = WorkoutSet(
                                reps: lastSet?.reps ?? 8,
                                weight: lastSet?.weight ?? (exercise.type == .weighted ? 20 : 0)
                            )
                            exercise.sets.append(newSet)
                        }
                        NavigationLink(value: exercise) {
                            Label("View progress", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if workout.exercises.isEmpty {
                ContentUnavailableView("No exercises yet", systemImage: "dumbbell")
            }
        }
        .toolbar {
            Button("Add exercise", systemImage: "plus") {
                isAddingExercise = true
            }
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseProgressView(exercise: exercise)
        }
        .sheet(isPresented: $isAddingExercise) {
            AddExerciseView(workout: workout)
        }
    }
}
