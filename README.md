# Cyber Stack - Neon Drop

Arcade stacking game built with Flutter and Flame. Stop each moving block with a
tap and keep the stack aligned as its width shrinks.

## Tech Stack

- Flutter 3.50.0
- Dart 3.14.0
- Flame Engine (`^1.18.0`, resolved to 1.38.2)
- Hive local storage dependency (high-score persistence is not implemented yet)

## Rules and Controls

- Tap once to stop the horizontally moving block.
- A block that completely misses the block below ends the game.
- A partial overlap trims the new block to the overlapping width and increases
  the score.
- The game ends when the stack reaches the top of the viewport.
- Each successful placement increases the speed, up to 600 logical pixels per
  second.

## Run

Run on Linux desktop:

```sh
flutter run -d linux
```

Run on a connected Android device:

```sh
flutter run -d <device-id>
```

List available devices with `flutter devices`. Run the test suite with
`flutter test`.
