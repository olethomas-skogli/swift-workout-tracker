//
//  AddWorkoutView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var date = Date.now
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                DatePicker("Date", selection: $date)
            }
            .navigationTitle("New workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let workout = Workout(
                            name: trimmedName,
                            date: date,
                            exercises: []
                        )
                        modelContext.insert(workout)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddWorkoutView()
        .modelContainer(for: Workout.self, inMemory: true)
}
