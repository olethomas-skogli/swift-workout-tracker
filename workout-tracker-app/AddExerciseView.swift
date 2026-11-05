//
//  AddExerciseView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import SwiftUI

struct AddExerciseView: View {
    let workout: Workout

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type = ExerciseType.weighted

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    ForEach(ExerciseType.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("New exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let exercise = Exercise(name: trimmedName, type: type, sets: [])
                        workout.exercises.append(exercise)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
