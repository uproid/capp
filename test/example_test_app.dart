import 'dart:io';
import 'package:capp/capp.dart';

void main(List<String> args) async {
  var helpOption = CappOption(
    name: 'help',
    shortName: 'h',
    description: 'Show help',
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
    // Note: Omit onKeyPress here so we drop down into `_processWhileLine`
    // which operates properly on piped stdin / stout for automated integration tests.
    controllers: [
      CappController(
        'test',
        description: 'Run a test',
        options: [
          CappOption(
              name: 'print',
              shortName: 'p',
              description: 'A value to print after test',
              value: "Default value"),
          helpOption,
        ],
        run: (c) async {
          if (c.existsOption('print')) {
            print(c.getOption('print', def: 'no value'));
          }
          CappConsole.write("Test Executed", CappColors.success);
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
    appLabel: () => "TestApp> ",
    initArgs: args,
  );
}
