//
//  ContentView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 03/11/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @State private var isAddingWorkout = false
    var body: some View {
        NavigationStack {
            List {
                if !workouts.isEmpty {
                    Section {
                        DashboardView(workouts: workouts)
                    }
                }
                Section("Workouts") {
                    ForEach(workouts) { workout in
                        NavigationLink(value: workout) {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                Text("\(workout.date.formatted(date: .abbreviated, time: .omitted)) · \(workout.summary)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(workouts[index])
                        }
                    }
                }

            }
            .navigationTitle("Gym tracker")
            .toolbar {
                Button("Add workout", systemImage: "plus") {
                    isAddingWorkout = true
                }
            }
            .sheet(isPresented: $isAddingWorkout) {
                AddWorkoutView()
            }
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
        // App-wide theme: dark surfaces and rounded type. Applied here (the root view)
        // so it also shows up in previews; it flows down to every pushed screen and sheet.
        .preferredColorScheme(.dark)
        .fontDesign(.rounded)
    }
}

#Preview("With workouts") {
    ContentView()
        .modelContainer(.preview)
}

#Preview("Empty") {
    ContentView()
        .modelContainer(for: Workout.self, inMemory: true)
}
