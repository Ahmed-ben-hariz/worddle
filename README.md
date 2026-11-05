# Worddle

An offline five-letter word puzzle for Android, iOS and web, built with Flutter, Material 3 and Riverpod.
Six guesses, colour feedback, a deterministic **Daily Challenge** (UTC) and unlimited **Practice** games.

> **Status:** this source tree was written without access to a Flutter SDK, so it has **not** been
> compiled, analyzed or run yet. See [First run](#first-run) - expect to spend a few minutes on
> `flutter analyze` / `flutter test` and fix any small issue it reports.

## Requirements

Flutter 3.24+ (Dart 3.5+). Check with `flutter --version`.

## First run

The repository contains `lib/`, `assets/`, `test/` and `pubspec.yaml`, but not the generated platform folders.

```bash
cd worddle
flutter create . --platforms=android,ios,web --project-name worddle   # adds android/ ios/ web/ (does not overwrite lib/ or test/widget_test.dart)
flutter pub get
flutter analyze
flutter test
flutter run                 # pick a device, e.g. -d chrome, an emulator, or a phone
```

If `flutter create` produced its own `test/widget_test.dart` counter test, delete it and keep the one from this repo.

## Features

* Daily Challenge: same word for everyone per UTC date, saved automatically, cannot be replayed once finished, rolls over at 00:00 UTC (checked on app resume and on submit).
* Practice: random answers, resumable, separate statistics.
* Correct duplicate-letter handling (two-pass algorithm in `wordle_engine.dart`).
* Custom QWERTY keyboard with stronger-status-wins colouring (correct > present > absent), physical keyboard support.
* Animations: staggered 3D tile flip, typing pop, invalid-word shake, win hop, animated key colours, fade/scale dialogs.
* Statistics (played, win %, current/max streak, distribution) - tracked separately for Daily and Practice.
* Light / dark / system theme, haptics toggle, all persisted. Sound is intentionally not implemented (no audio assets bundled).
* Spoiler-free emoji share text (`Worddle #42 3/6`), via `share_plus` with a clipboard fallback.

## Architecture

```
lib/
  core/            constants (AppColors + GameColors theme extension), theme, UTC date utils, providers, haptics
  features/
    game/
      domain/      models (GameState, WordList, LetterStatus...), services (WordleEngine, DailyWordService, ShareTextBuilder) - no Flutter widgets
      data/        WordRepository (assets), GameStorage (SharedPreferences, defensive parsing)
      presentation/ GameController (Riverpod Notifier), GameScreen, grid/row/tile/keyboard/dialog widgets
    statistics/    GameStats model, StatsNotifier, StatisticsScreen
    settings/      AppSettings, SettingsNotifier, SettingsScreen
    help/          HowToPlayDialog
  shared/widgets/  PrimaryButton, animated dialog / route helpers
assets/words/      answers.txt, valid_guesses.txt, LICENSE_WORDS.md
test/              engine, daily service, controller, storage/stats, word list, widgets
```

Data flow: widgets -> `GameController` (rules, persistence, animation timing) -> `WordleEngine` / `GameStorage`.
Infrastructure (prefs, word list, clock, random, animation timings) is injected through Riverpod providers, which is how tests control time and words.

## Word lists

* `valid_guesses.txt` (about 14.9k words) is the five-letter subset of [dwyl/english-words](https://github.com/dwyl/english-words) (Unlicense). It contains some obscure words, which is intentional for generous guess validation.
* `answers.txt` (~1,000 common words) is hand-curated, shuffled once, and **append-only**: the daily word is `answers[(challengeNumber - 1) % length]` with challenge #1 = 2026-01-01 UTC. Never reorder or delete entries.
* Dictionaries are validated on load (answers strictly, guesses leniently), lower-cased and de-duplicated. No network is ever used.

## Design decisions / trade-offs

* Daily vs practice stats are separate objects; abandoning a practice game by starting a new one is not counted.
* Daily streaks require consecutive UTC days (a missed day resets the displayed streak).
* Stats are saved before the reveal animation finishes, so quitting mid-animation cannot lose or double-count a result.
* `share_plus` is the only extra dependency beyond the requested stack (native sharing).
* No custom fonts are bundled, to keep the project dependency- and asset-light.
