import 'dart:convert';
import 'dart:io';
import 'capp_controller.dart';
import 'capp_console.dart';
import 'capp_option.dart';
import 'cappout.dart';

/// [CappManager] is a class that represents the manager of the console application.
/// The manager is a class that contains the main logic of the application.
class CappManager {
  // History of commands entered by the user. Each entry is a list of strings representing the command and its arguments.
  var history = <List<String>>[];

  void addOnWrite(CoutEvent on) {
    Cout.addOnWrite(on);
  }

  void removeOnWrite(CoutEvent on) {
    Cout.removeOnWrite(on);
  }

  /// The flag used to chain multiple commands in a single input (e.g. `test -p --and help`).
  static const chainFlag = '--and';

  /// [controllers] contin all contin all CappControllers that you can use in the app
  List<CappController> controllers;

  /// [args] is a list of arguments that passed to the application from the console.
  List<String> args;

  /// [main] is the main controller of the application. when the application starts the main controller will be called.
  CappController main;

  Function(Key key, CappManager manager)? onKeyPress;

  /// The constructor of the CappManager class.
  /// The [main] is the main controller of the application.
  /// The [args] is a list of arguments that passed to the application from the console.
  /// The [controllers] is a list of controllers that can be called from the console.
  CappManager({
    required this.main,
    required this.args,
    required this.controllers,
    this.onKeyPress,
  });

  /// The [process] method is used to process the arguments and call the controllers.
  /// Call this function to start the application.
  Future<void> process({List<String>? newArgs}) async {
    args = newArgs ?? args;
    if (args.isEmpty) {
      main.init(manager: this);
      var res = await main.run(main);
      res.log();
      return;
    }

    if (history.isEmpty) {
      history.add(args);
    } else if (history.last.join(' ') != args.join(' ')) {
      history.add(args);
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
    @Deprecated('Use appLabel instead') String promptLabel = 'App> ',

    /// [appLabel] is a function that returns the label of the prompt.
    /// It will be called before each prompt.
    /// You can use it to show dynamic labels.
    String Function()? appLabel,
    List<String>? initArgs,
  }) async {
    if (appLabel == null) {
      appLabel = () => promptLabel;
    } else {
      promptLabel = appLabel();
    }
    if (initArgs != null && initArgs.isNotEmpty) {
      await _processChain(initArgs);
    }

    if (onKeyPress != null) {
      await _processWhileRaw(appLabel);
    } else {
      await _processWhileLine(appLabel);
    }
  }

  Future _processWhileLine(String Function() appLabel) async {
    final input = stdin.transform(utf8.decoder);
    Cout.write(appLabel());

    await for (String line in input.transform(LineSplitter())) {
      line = line.trim();
      line = line.replaceAll(RegExp('  '), ' ');
      if (line.isNotEmpty) {
        await _processChain(line.split(' '));
      }
      Cout.write(appLabel());
    }
  }

  /// Splits [fullArgs] on [chainFlag] (`--and`) and runs each resulting
  /// command in sequence, announcing the next command before it runs.
  Future<void> _processChain(List<String> fullArgs) async {
    var commands = <List<String>>[[]];
    for (var arg in fullArgs) {
      if (arg == chainFlag) {
        commands.add([]);
      } else {
        commands.last.add(arg);
      }
    }
    commands = commands.where((command) => command.isNotEmpty).toList();
    if (commands.isEmpty) return;

    for (var i = 0; i < commands.length; i++) {
      args = commands[i];
      await process();

      if (i < commands.length - 1) {
        CappConsole.write(
          "Next command: ${commands[i + 1].join(' ')}",
          CappColors.info,
        );
      }
    }
  }

  Future _processWhileRaw(String Function() appLabel) async {
    stdin.lineMode = false;
    stdin.echoMode = false;

    try {
      var buffer = StringBuffer();
      CappConsole.setActiveBuffer(buffer, appLabel());
      Cout.write(appLabel());

      while (true) {
        int byte = stdin.readByteSync();
        if (byte < 0) break;

        var key = _parseKey(byte);
        onKeyPress!(key, this);

        if (key.controlChar == ControlCharacter.ctrlC) {
          Cout.writeln();
          break;
        } else if (key.controlChar == ControlCharacter.enter) {
          Cout.writeln();
          var line = buffer.toString().trim().replaceAll(RegExp('  '), ' ');
          buffer.clear();
          if (line.isNotEmpty) {
            // Restore line mode for command processing output
            stdin.lineMode = true;
            stdin.echoMode = true;
            await _processChain(line.split(' '));
            stdin.lineMode = false;
            stdin.echoMode = false;
          }
          Cout.write(appLabel());
        } else if (byte == 127 || byte == 8) {
          // Backspace
          if (buffer.isNotEmpty) {
            var str = buffer.toString();
            buffer.clear();
            buffer.write(str.substring(0, str.length - 1));
            Cout.write('\b \b');
          }
        } else if (key.controlChar == ControlCharacter.none && byte >= 32) {
          // Printable character
          buffer.write(key.char);
          Cout.write(key.char);
        }
      }
    } finally {
      CappConsole.clearActiveBuffer();
      stdin.lineMode = true;
      stdin.echoMode = true;
    }
  }

  Key _parseKey(int byte) {
    if (byte == 3) {
      return Key('', ControlCharacter.ctrlC);
    } else if (byte == 13 || byte == 10) {
      return Key('', ControlCharacter.enter);
    } else if (byte == 27) {
      int next1 = stdin.readByteSync();
      if (next1 == 91) {
        int next2 = stdin.readByteSync();
        if (next2 == 65) return Key('', ControlCharacter.arrowUp);
        if (next2 == 66) return Key('', ControlCharacter.arrowDown);
        if (next2 == 67) return Key('', ControlCharacter.arrowRight);
        if (next2 == 68) return Key('', ControlCharacter.arrowLeft);
      }
      return Key('', ControlCharacter.escape);
    }
    return Key(String.fromCharCode(byte), ControlCharacter.none);
  }

  /// The [getHelp] method is used to get the help of the application.
  /// The [myControllers] is a list of controllers that you want to show in the help. If it is null it will show all controllers.
  /// you can call this method from the controller to get the help of the application.
  String getHelp([List<CappController>? myControllers]) {
    var selectedControllers = myControllers ?? [...controllers, main];
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

  static void cwrite(String text, [CappColors color = CappColors.none]) {
    switch (color) {
      case CappColors.warning:
        Cout.writeln('\x1B[33m$text\x1B[0m');
      case CappColors.error:
        Cout.writeln('\x1B[31m$text\x1B[0m');
      case CappColors.success:
        Cout.writeln('\x1B[32m$text\x1B[0m');
      case CappColors.info:
        Cout.writeln('\x1B[36m$text\x1B[0m');
      default:
        Cout.writeln(text);
    }
  }

  /// The [writeHelpModern] method is used to write the help of the application in a modern way.
  /// The [myControllers] is a list of controllers that you want to show in the
  /// help. If it is null it will show all controllers.
  /// you can call this method from the controller to write the help of the application in a modern way.
  /// This method uses ANSI escape codes to color the output and make it more readable.
  ///
  /// Controllers whose name contains a colon (e.g. `test:subtest`) are treated
  /// as sub-commands of the part before the colon (`test`). They are grouped
  /// under a single namespace header instead of being listed as independent,
  /// unrelated commands, which keeps the help output readable as the number
  /// of sub-commands grows.
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

    var groupOrder = <String>[];
    var groups = <String, List<CappController>>{};
    for (var controller in selectedControllers) {
      var key = controller.name.contains(':')
          ? controller.name.split(':').first
          : controller.name;
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(controller);
      if (!groupOrder.contains(key)) {
        groupOrder.add(key);
      }
    }

    for (var key in groupOrder) {
      var members = groups[key]!;
      var isNamespace = key.isNotEmpty && members.any((c) => c.name != key);

      if (!isNamespace) {
        for (var controller in members) {
          _writeControllerHelp(controller, maxNameLen);
        }
        continue;
      }

      CappController? parent;
      for (var member in members) {
        if (member.name == key) {
          parent = member;
        }
      }

      _printCommandLine('✔ $key', parent?.description ?? '');
      if (parent != null) {
        _writeOptions(parent, maxNameLen);
      }

      for (var member in members) {
        if (member == parent) {
          continue;
        }
        _printCommandLine('✔ ${member.name}', member.description,
            indent: '\n\t');
        _writeOptions(member, maxNameLen, indent: '\t');
      }
    }

    return CappConsole('');
  }

  void _writeControllerHelp(CappController controller, int maxNameLen) {
    if (controller.name.isNotEmpty) {
      _printCommandLine('✔ ${controller.name}', controller.description);
    } else {
      cwrite(controller.description, CappColors.info);
    }
    _writeOptions(controller, maxNameLen);
  }

  /// Prints a command name (bold green) with its description (yellow) on the
  /// same line, separated by a tab, instead of on the line below it.
  void _printCommandLine(String label, String description,
      {String indent = ''}) {
    var line = '$indent\x1B[32m\x1B[1m$label\x1B[22m\x1B[0m';
    if (description.isNotEmpty) {
      line += '\t\x1B[33m$description\x1B[0m';
    }
    Cout.writeln(line);
  }

  void _writeOptions(
    CappController controller,
    int maxNameLen, {
    String indent = '',
  }) {
    for (var option in controller.options) {
      if (option.hideInHelp) {
        continue;
      }
      var nameCol = '--${option.name}'.padRight(maxNameLen + 2);
      cwrite("$indent\t-${option.shortName}, $nameCol ${option.description}");
    }
  }
}
