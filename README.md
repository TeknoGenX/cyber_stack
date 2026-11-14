# Cyber Stack - Neon Drop

Arcade stacking game built with Flutter and Flame. Stop each moving block with a
tap and keep the stack aligned as its width shrinks.

## Tech Stack

- Flutter 3.50.0
- Dart 3.14.0
- Flame Engine (`^1.18.0`, resolved to 1.38.2)
- Flame Audio (`^2.12.2`) for sound effects
- Hive local storage for the high score and sound preference

## Rules and Controls

- The first tap starts the game; the first moving block starts aligned with the
  base block.
- Tap again to stop the horizontally moving block.
- A block that completely misses the block below ends the game.
- A partial overlap trims the new block to the overlapping width and increases
  the score.
- Centered placements build a combo streak; each streak level adds that many
  bonus points. A non-centered placement resets the combo.
- The game ends when the stack reaches the top of the viewport.
- Each successful placement increases the speed, up to 600 logical pixels per
  second.
- The best score is saved locally and shown below the current score.
- Placement, combo, and game-over events have sound effects.
- Use the sound button to mute or enable effects; the preference is saved locally.
- Use the pause button in the upper-right corner to pause or resume a game.
- Tap again after `GAME OVER` to restart.

## Run

Linux audio builds require GTK 3 and GStreamer development packages, including
`libgtk-3-dev`, `libgstreamer1.0-dev`, and
`libgstreamer-plugins-base1.0-dev` on Debian-based systems.

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
