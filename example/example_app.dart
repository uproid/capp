import 'dart:io';

import 'package:capp/capp.dart';

void main(List<String> args) async {
  int historyIndex = 0;

  var helpOption = CappOption(
    name: 'help',
    shortName: 'h',
    description: 'Show help for this command',
    hideInHelp: true,
    onSelect: (controller) {
      controller.writeHelp();
      return false;
    },
  );

  CappManager capp = CappManager(
    main: CappController(
      'help',
      options: [helpOption],
      run: (c) async => c.manager.writeHelpModern(),
      description: 'Show commands help',
    ),
    args: args,
    onKeyPress: (key, manager) {
      if (key.controlChar == ControlCharacter.enter) {
        historyIndex = 0;
      }

      if (key.controlChar == ControlCharacter.arrowUp &&
          historyIndex < manager.history.length) {
        historyIndex++;
        var command = manager.history[manager.history.length - historyIndex];
        CappConsole.removeCommandBar();
        CappConsole.addToCommandBar(command.join(' '));
      } else if (key.controlChar == ControlCharacter.arrowDown &&
          historyIndex > 1) {
        historyIndex--;
        var command = manager.history[manager.history.length - historyIndex];
        CappConsole.removeCommandBar();
        CappConsole.addToCommandBar(command.join(' '));
      }
    },
    controllers: [
      CappController(
        'test',
        description: 'Run a test',
        options: [
          CappOption(
            name: 'quit',
            shortName: 'q',
            description: 'Quit after test',
          ),
          CappOption(
            name: 'print',
            shortName: 'p',
            description: 'A value to print after test',
            value: "Default value",
          ),
          helpOption,
        ],
        run: (c) async {
          if (c.existsOption('print')) {
            print(c.getOption('print', def: 'no value'));
          }
          CappConsole.write(
            "Test ${DateTime.now()}",
            CappColors.success,
          );

          if (c.existsOption('quit')) {
            exit(0);
          }

          return CappConsole.empty;
        },
      ),
      // Namespaced sub-commands: any controller whose name contains a colon
      // (`namespace:subcommand`) is called exactly like a normal command,
      // e.g. `test:subtest -i=5`, but writeHelpModern() groups it under its
      // namespace ("test") instead of listing it as an unrelated command.
      CappController(
        'test:subtest',
        description: 'Run a single sub-test by its index',
        options: [
          CappOption(
            name: 'iter',
            shortName: 'i',
            description: 'Index of the sub-test to run',
            value: '1',
          ),
          helpOption,
        ],
        run: (c) async {
          var iter = c.getOption('iter', def: '1');
          CappConsole.write(
            "Running sub-test #$iter",
            CappColors.success,
          );
          return CappConsole.empty;
        },
      ),
      CappController(
        'test:report',
        description: 'Show a report of the last test run',
        options: [helpOption],
        run: (c) async {
          CappConsole.write(
            "Test report generated at ${DateTime.now()}",
            CappColors.success,
          );
          return CappConsole.empty;
        },
      ),
      CappController(
        'exit',
        description: 'Exit the application',
        options: [helpOption],
        run: (c) async => exit(0),
      ),
    ],
  );

  await capp.processWhile(
    appLabel: () {
      var now = DateTime.now();
      String formattedTime = "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
      return "$formattedTime App> ";
    },
    initArgs: args,
  );
}
