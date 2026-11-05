//
//  SetRowView.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 04/11/2026.
//

import SwiftUI

struct SetRowView: View {
    @Bindable var set: WorkoutSet
    let number: Int
    let type: ExerciseType

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .leading)

            Spacer()
            if type == .weighted {
                TextField("0", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 64)
                    .padding(.vertical, 6)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                Text("kg")
                    .foregroundStyle(.secondary)
            }

            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 48)
                .padding(.vertical, 6)
                .background(.fill.tertiary, in: .rect(cornerRadius: 8))
            Text("reps")
                .foregroundStyle(.secondary)
        }
    }
}
