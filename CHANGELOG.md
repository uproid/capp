## 2.0.0
- [#3](https://github.com/uproid/capp/issues/3) Added command chaining: pass `--and` between commands (e.g. `test -p hello --and help --and exit`) to run several commands, one after another, in a single invocation. Works for the initial CLI arguments as well as for lines typed at the interactive prompt (both line mode and raw mode). Before each next command runs, a `Next command: ...` message is printed. `--and` is only used as a separator, it's never forwarded to controllers/options and never appears in the generated help.
- Added `example/example_chain.dart` demonstrating the new command chaining feature.
- Added a GitHub Actions workflow to run the test suite on every push/PR.
- Greatly expanded the test suite: unit tests for `CappManager`, `CappConsole`, and `CappOption`, plus integration tests that spawn the example apps to verify one-shot argument processing, interactive stdin sessions, and command chaining end-to-end.

## 1.1.8
- Added command history tracking to `CappManager`, allowing navigation through previously entered commands using arrow keys
- Added `onKeyPress` callback to `CappManager` for handling raw mode key events, enabling custom key bindings
- Added dynamic `appLabel` parameter to `processWhile` (replaces deprecated `promptLabel`), allowing prompt labels that update on each iteration (e.g., showing current time)
- Added `removeCommandBar` and `addToCommandBar` static methods to `CappConsole` for manipulating the command bar text in raw mode
- Added `eventListen` method to `CappConsole` for stdin event listening
- Updated `example_app.dart` to demonstrate command history navigation and dynamic prompt labels

## 1.1.7
- Added `resetValue` method to `CappOption` to reset the option's value to its default value and set `existsInArgs` to false. This allows for easier reuse of options across multiple command executions without retaining previous values, ensuring that each command starts with a clean slate for its options. The `resetValue` method is called in the `CappManager` before processing each command to ensure that options are reset before being populated with new values from the command arguments.

## 1.1.6
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