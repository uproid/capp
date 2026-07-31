import 'dart:io';
import 'package:capp/capp.dart';

/// This example shows how to run several commands in a row, in a single
/// invocation, using the `--and` flag as a separator between commands.
///
/// Try it:
///   dart example/example_chain.dart test -p hello --and test -p world --and help --and exit
///
/// Each command runs one after another, and before every next command a
/// "Next command: ..." message is printed. The `--and` flag is only used
/// to split commands, it is never passed to any controller/option and it
/// never shows up in the generated help.
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
            name: 'print',
            shortName: 'p',
            description: 'A value to print after test',
            value: 'Default value',
          ),
          helpOption,
        ],
        run: (c) async {
          CappConsole.write(c.getOption('print', def: 'no value'));
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

  // initArgs is split on `--and`, and each resulting command runs in
  // sequence. This also works for lines typed at the interactive prompt.
  await capp.processWhile(
    appLabel: () => 'Chain> ',
    initArgs: args,
  );
}
