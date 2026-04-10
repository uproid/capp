import 'dart:convert';
import 'dart:io';

import 'capp_controller.dart';
import 'capp_console.dart';
import 'capp_option.dart';

/// [CappManager] is a class that represents the manager of the console application.
/// The manager is a class that contains the main logic of the application.
class CappManager {
  /// [controllers] contin all contin all CappControllers that you can use in the app
  List<CappController> controllers;

  /// [args] is a list of arguments that passed to the application from the console.
  List<String> args;

  /// [main] is the main controller of the application. when the application starts the main controller will be called.
  CappController main;

  /// The constructor of the CappManager class.
  /// The [main] is the main controller of the application.
  /// The [args] is a list of arguments that passed to the application from the console.
  /// The [controllers] is a list of controllers that can be called from the console.
  CappManager({
    required this.main,
    required this.args,
    required this.controllers,
  });

  /// The [process] method is used to process the arguments and call the controllers.
  /// Call this function to start the application.
  Future<void> process() async {
    if (args.isEmpty) {
      main.init(manager: this);
      var res = await main.run(main);
      res.log();
      return;
    }

    try {
      for (var controller in controllers) {
        controller.init(manager: this);

        if (controller.name == args[0]) {
          for (var option in controller.options) {
            option.resetValue();
            final find = _findOptionValue(args, option);
            option.value = find.value;
            option.existsInArgs = find.exist;
            if (controller.existsOption(option.name) &&
                option.onSelect != null) {
              var res = option.onSelect!(controller);
              if (!res) {
                return;
              }
            }
          }

          var res = await controller.run(controller);
          res.log();
          return;
        }
      }

      main.init(manager: this);
      for (var option in main.options) {
        option.resetValue();
        final find = _findOptionValue(args, option);
        option.value = find.value;
        option.existsInArgs = find.exist;
      }

      var res = await main.run(main);
      res.log();
      return;
    } catch (e) {
      CappConsole.write("Error: ${e.toString()}", CappColors.error);
    }
    writeHelpModern();
  }

  Future processWhile({
    String promptLabel = 'App> ',
    List<String>? initArgs,
  }) async {
    if (initArgs != null && initArgs.isNotEmpty) {
      args = initArgs;
      await process();
    }

    final input = stdin.transform(utf8.decoder);
    stdout.write(promptLabel);

    await for (String line in input.transform(LineSplitter())) {
      line = line.trim();
      line = line.replaceAll(RegExp('  '), ' ');
      if (line.isNotEmpty) {
        args = line.split(' ');
        await process();
      }
      stdout.write(promptLabel);
    }
  }

  /// The [getHelp] method is used to get the help of the application.
  /// The [myControllers] is a list of controllers that you want to show in the help. If it is null it will show all controllers.
  /// you can call this method from the controller to get the help of the application.
  String getHelp([List<CappController>? myControllers]) {
    var selectedControllers = myControllers ?? [...this.controllers, main];
    var help = "Available commands:\n";
    var index = 1;
    for (var controller in selectedControllers) {
      if (controller.name.isNotEmpty) {
        help += "${index++}) ${controller.name}:\t${controller.description}\n";
      } else {
        help += "${controller.description}\n";
      }
      if (controller.options.isNotEmpty) {
        help += "\n";
      }

      var indexOption = 0;
      for (var option in controller.options) {
        indexOption++;

        help += "      --${option.name}\t${option.description}\n";
        if (option.shortName.isNotEmpty) {
          help += "      -${option.shortName}\n";
        } else {
          help += "\n";
        }

        if (indexOption < controller.options.length) {
          help += "\n";
        }
      }

      help += "${'─' * 30}\n";
    }

    return help;
  }

  ({String value, bool exist}) _findOptionValue(
    List<String> args,
    CappOption option,
  ) {
    var exist = false;
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg.startsWith('--${option.name}') ||
          arg.startsWith('-${option.shortName}')) {
        exist = true;

        if (args.length > i + 1) {
          var nextArg = args[i + 1];
          if (!nextArg.startsWith('-')) {
            return (value: nextArg, exist: exist);
          }
        }
      }

      if (arg.contains('=')) {
        var parts = arg.split('=');
        if (parts[0] == '--${option.name}' ||
            parts[0] == '-${option.shortName}') {
          return (value: parts[1], exist: true);
        }
      }
    }
    return (value: option.value, exist: exist);
  }

  static void cprint(String text, [CappColors color = CappColors.none]) {
    switch (color) {
      case CappColors.warning:
        print('\x1B[33m$text\x1B[0m');
      case CappColors.error:
        print('\x1B[31m$text\x1B[0m');
      case CappColors.success:
        print('\x1B[32m$text\x1B[0m');
      case CappColors.info:
        print('\x1B[36m$text\x1B[0m');
      default:
        print(text);
    }
  }

  /// The [writeHelpModern] method is used to write the help of the application in a modern way.
  /// The [myControllers] is a list of controllers that you want to show in the
  /// help. If it is null it will show all controllers.
  /// you can call this method from the controller to write the help of the application in a modern way.
  /// This method uses ANSI escape codes to color the output and make it more readable.
  CappConsole writeHelpModern([List<CappController>? myControllers]) {
    var selectedControllers = myControllers ?? [...controllers, main];

    var maxNameLen = 0;
    for (var controller in selectedControllers) {
      for (var option in controller.options) {
        if (option.hideInHelp) {
          continue;
        }
        if (option.name.length > maxNameLen) {
          maxNameLen = option.name.length;
        }
      }
    }

    for (var controller in selectedControllers) {
      if (controller.name.isNotEmpty) {
        cprint("\x1B[1m✔ ${controller.name}\x1B[22m", CappColors.success);
        if (controller.description.isNotEmpty) {
          cprint("\t${controller.description}", CappColors.warning);
        }
      } else {
        cprint(controller.description, CappColors.info);
      }
      for (var option in controller.options) {
        if (option.hideInHelp) {
          continue;
        }
        var nameCol = '--${option.name}'.padRight(maxNameLen + 2);
        cprint("\t-${option.shortName}, $nameCol ${option.description}");
      }
    }

    return CappConsole('');
  }
}
