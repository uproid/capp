import 'dart:io';

import 'package:capp/capp.dart';

void main(List<String> args) async {
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
      CappController(
        'exit',
        description: 'Exit the application',
        options: [helpOption],
        run: (c) async => exit(0),
      ),
    ],
  );

  await capp.processWhile(
    promptLabel: 'APP > ',
    initArgs: args,
  );
}
