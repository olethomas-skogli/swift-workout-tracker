//
//  workout_tracker_appApp.swift
//  workout-tracker-app
//
//  Created by Ole Thomas Skogli on 03/11/2026.
//

import SwiftData
import SwiftUI

@main
struct workout_tracker_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Workout.self)
    }
}
