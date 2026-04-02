## 1.1.5
- Added `onSelect` callback to `CappOption` to allow executing a function when an option is selected, even if it doesn't have a command associated with it. This is useful for options that are meant to trigger an action without requiring additional input, such as displaying help or toggling a setting.

## 1.1.4
- Added `_readKey` method to handle key inputs
- Supported arguments with `=` in the `_findOptionValue` method, allowing options to be passed as `--option=value` or `-o=value`
- Added `writeHelpModern` method to display help in a more modern and colorful way using ANSI escape codes
- Supported breaking the loop in `processWhile` by pressing the 'q' key, allowing users to exit the command processing loop gracefully while still receiving new commands
  
## 1.1.2
- Added `processWhile` to keep the app running while receiving new commands, check `example_app.dart`

## 1.1.1
- Fixes #1 warning color

## 1.1.0
- Added Json View
- Added Menu View
- Added Multi Choice View

## 1.0.3
- Fixed bug

## 1.0.2
- Added Progress timer

## 1.0.1
- Fixed bug
- Added documentation
- Added example

## 1.0.0
- Deploy Capp package to pub