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
  void process() async {
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
            final find = _findOptionValue(args, option);
            option.value = find.value;
            option.existsInArgs = find.exist;
          }

          var res = await controller.run(controller);
          res.log();
          return;
        }
      }

      main.init(manager: this);
      for (var option in main.options) {
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
    CappConsole.write(getHelp(), CappColors.warning);
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
      List<String> args, CappOption option) {
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
    }
    return (value: option.value, exist: exist);
  }
}
