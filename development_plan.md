# ArvyaX Flutter Assessment - Development Plan

Given that this is a demo/assessment app, the goal is to implement a **clean, correct, and premium** experience without over-engineering. We will focus strictly on the required features and opt for the easiest persistence and bonus options to save time.

## Phase 1: Setup & Architecture (Minimal Foundation)
- [ ] Initialize standard Flutter project and clear `main.dart`.
- [ ] Set up clean folder structure: `data/`, `features/`, `shared/`.
- [ ] Add basic dependencies: `flutter_riverpod` (State), `just_audio` (Playback), `hive` or `shared_preferences` (Persistence).
- [ ] Set up `shared/theme` with basic typography, colors, and the "minimal/premium" Apple-like styling.

## Phase 2: Data & State
- [ ] **Ambience Data:** Create local `ambiences.json` (6 items) and load it via a simple repository.
- [ ] **State Management:** Implement Riverpod providers for:
  - Filtering/Searching ambiences.
  - Journal entry history.
  - Active session state/timer.

## Phase 3: Core Features (UI & Logic)
- [ ] **Home Screen:** 
  - Search bar + Tag Filter Chips.
  - Ambience List/Grid UI & Empty State ("No ambiences found").
- [ ] **Ambience Details Screen:** Hero image, Title, Tags, Description, Sensory Chips, and "Start Session".
- [ ] **Session Player Screen:** 
  - Play/Pause toggle, Seek bar, Time counters.
  - Subtly animated background (e.g., simple `AnimatedContainer` breathing gradient).
  - Audio looping logic linked to a countdown timer.
  - "End Session" confirmation dialog.
- [ ] **Mini Player Widget:** A generic bottom component visible on Home & Details when a session is active.

## Phase 4: Journaling & History
- [ ] **Reflection Screen:** Prompt text, Multi-line text field, 4 Mood selection chips, "Save" button.
- [ ] **History Screen:** Simple List view of saved reflections with empty state. Detail view dialog on tap.

## Phase 5: Polish & Deliverables
- [ ] **Bonus Feature:** Implement Haptic Feedback (Option 4) – it's the fastest to do and adds immediate premium feel using Flutter's native `HapticFeedback`.
- [ ] **README:** Write a clean README detailing architecture, state flow, and package justification.
- [ ] **Final Review:** Ensure no layout breaks on small/large screens and record the 30-60s showcase video.
