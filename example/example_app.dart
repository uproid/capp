import 'dart:io';

import 'package:capp/capp.dart';

void main(List<String> args) async {
  CappManager capp = CappManager(
    main: CappController(
      'help',
      options: [],
      run: (c) async => CappConsole(c.manager.getHelp()),
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
        ],
        run: (c) async {
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
        options: [],
        run: (c) async => exit(0),
      ),
    ],
  );

  await capp.processWhile(
    promptLabel: 'APP > ',
    initArgs: args,
  );
}
