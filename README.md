# Swift Workout Tracker

A gym workout tracker for iPhone, built with SwiftUI and SwiftData as a 4-day project to learn Swift.

## Features

- Log workouts, exercises and sets (reps and weight), with weighted and bodyweight exercise types
- Collapsible exercise cards with set count, volume and best set
- Front-page dashboard: weekly streak, this week's days, stat tiles and a weekly volume chart
- Per-exercise progress chart with personal record and change since first workout
- Dark theme with a volt accent color
- All data stored on-device with SwiftData

## Requirements

- Xcode 27 or later
- iOS 26.0 or later (simulator or device)

## Getting started

1. Clone the repo and open `workout-tracker-app.xcodeproj` in Xcode.
2. Choose an iPhone simulator in the toolbar and press **⌘R** to run.
3. To run on your own iPhone, select your team under **Signing & Capabilities** for the `workout-tracker-app` target.

## Tests

Unit tests use Swift Testing and an in-memory SwiftData database, so they never touch real data.

- In Xcode: press **⌘U**
- From Terminal:

  ```bash
  xcodebuild test -scheme workout-tracker-app -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
  ```

## Project structure

```
Shared/                       Code shared by the iPhone app (and a future Watch app)
├── Models/Workout.swift      SwiftData models: Workout, Exercise, WorkoutSet, ExerciseType
└── Logic/WorkoutStats.swift  Weekly volume, streak and week-view calculations

workout-tracker-app/          iPhone app
├── workout_tracker_appApp.swift
├── Views/
│   ├── ContentView.swift           Front page: dashboard and workout history
│   ├── DashboardView.swift         Streak, stat tiles and weekly volume chart
│   ├── WorkoutDetailView.swift     Exercises and sets for one workout
│   ├── SetRowView.swift            Editable row for one set
│   ├── ExerciseProgressView.swift  Progress chart and stats for one exercise
│   ├── AddWorkoutView.swift        Sheet for creating a workout
│   └── AddExerciseView.swift       Sheet for creating an exercise
├── Preview Content/
│   └── PreviewData.swift           Sample data for SwiftUI previews only
└── Assets.xcassets

workout-tracker-appTests/     Swift Testing suites for the Shared code
```

Code in `Shared/` must only use Foundation and SwiftData (no SwiftUI views or iOS-only APIs), so it can be added to other targets such as a watchOS app.

## Code style

Formatting uses [swift-format](https://github.com/swiftlang/swift-format) with the project's `.swift-format` config (4-space indentation). In Xcode: **Editor → Structure → Format File with 'swift-format'** (⌃⇧I).
