import 'dart:io';

/// [CappConsole] is a class that helps you to interact with the console.
/// Here are some Console widgets that you can use
class CappConsole {
  dynamic output;
  CappColors color;
  bool space;

  /// [CappConsole] is a class that helps you to interact with the console.
  CappConsole(this.output, [this.color = CappColors.info, this.space = false]);

  /// [log] method is used to print the output to the console.
  log() {
    var space = this.space ? '\n\n' : '';
    switch (color) {
      case CappColors.warnnig:
        print('\x1B[33m$space$output$space\x1B[0m');
        break;
      case CappColors.error:
        print('\x1B[31m$space$output$space\x1B[0m');
        break;
      case CappColors.success:
        print('\x1B[32m$space$output$space\x1B[0m');
        break;
      case CappColors.info:
        print('\x1B[36m$space$output$space\x1B[0m');
        break;
      case CappColors.none:
        print(output);
      case CappColors.off:
        break;
      default:
        print(output);
    }
  }

  /// [write] method is used to print the output to the console.
  static write(dynamic obj,
      [CappColors color = CappColors.none, space = false]) {
    CappConsole("${space ? '\n\n' : ''}$obj${space ? '\n\n' : ''}", color)
        .log();
  }

  /// [clear] method is used to clear the console screen.
  static void clear() {
    if (Platform.isWindows) {
      Process.runSync('cls', [], runInShell: true);
    } else {
      stdout.write('\x1B[2J\x1B[0;0H');
    }
  }

  /// [read] method is used to read the input from the console.
  static String read(
    String message, {
    bool isRequired = false,
    bool isNumber = false,
    bool isSlug = false,
  }) {
    stdout.write('\n\n$message ');
    var res = stdin.readLineSync() ?? '';
    res = res.trim();
    if (res.isEmpty && isRequired) {
      return read(
        message,
        isRequired: isRequired,
        isNumber: isNumber,
        isSlug: isSlug,
      );
    }

    if (isNumber) {
      var num = int.tryParse(res);
      if (num == null) {
        write("Input most be Integer!", CappColors.error);
        return read(
          message,
          isRequired: isRequired,
          isNumber: isNumber,
          isSlug: isSlug,
        );
      }

      res = num.toString();
    }

    if (isSlug && !_isSlug(res)) {
      write("input should be slug (like: example_name)", CappColors.error);
      return read(
        message,
        isRequired: isRequired,
        isNumber: isNumber,
        isSlug: isSlug,
      );
    }

    return res;
  }

  static bool _isSlug(String str) {
    var res = str.trim().toLowerCase();
    RegExp regex = RegExp(r'[^a-z]');
    res = res.replaceAll(regex, '');
    return res == str;
  }

  /// [progress] method is used to show the progress widget of the action.
  /// It can be a spinner, bar, or circle.
  /// The [message] is the message that will be shown in the console.
  /// The [action] is the action that will be executed.
  /// The [type] is the type of the progress widget.
  /// The [CappProgressType] is an enum that contains three types of progress widgets.
  static Future<T> progress<T>(
    String message,
    Future<T> Function() action, {
    CappProgressType type = CappProgressType.bar,
  }) async {
    bool isLoading = true;
    bool isWindows = Platform.isWindows;

    Future<void> showSpinner() async {
      var startTime = DateTime.timestamp();
      String spinner(int index) {
        if (type == CappProgressType.bar) {
          var res = '';
          var back = '█';
          var front = '░';
          for (var i = 0; i < 30; i++) {
            if (i == index) {
              res += front;
            } else {
              res += back;
            }
          }
          return res;
        } else if (type == CappProgressType.circle) {
          var rotating = '⣿⣷⣯⣟⡿⢿⣻⣽⣾';
          return "\t\t" + rotating[(index ~/ 1.5) % rotating.length] + ' ';
        } else if (type == CappProgressType.timer) {
          var time = DateTime.timestamp().difference(startTime);
          return '\t\t${time.inSeconds}.${time.inMilliseconds ~/ 100 % 10}s ';
        } else {
          var res = '|';
          for (var i = 0; i < 30; i++) {
            if (i == index) {
              res += '>';
            } else {
              res += '-';
            }
          }
          res += '|';
          return res;
        }
      }

      int spinnerIndex = 0;

      if (!isWindows) {
        stdin.lineMode = false;
        stdin.echoMode = false;
      }

      while (isLoading) {
        stdout.write('\r$message ${spinner(spinnerIndex)}');
        if (type != CappProgressType.circle) {
          spinnerIndex = (spinnerIndex + 1) % 30;
        } else {
          spinnerIndex++;
        }
        await Future.delayed(Duration(milliseconds: 50));
      }
    }

    var spinnerFuture = showSpinner();

    try {
      T result = await action();
      return result;
    } finally {
      if (!isWindows) {
        stdin.lineMode = true;
        stdin.echoMode = true;
      }
      isLoading = false;
      await spinnerFuture;
      stdout.write('\r$message\t\tDone!                            \n');
    }
  }

  /// [select] method is used to select an option from the list of options.
  /// The [message] is the message that will be shown in the console.
  /// The [options] is the list of options.
  /// The [isRequired] is a boolean that indicates if the option is required or not.
  /// The method returns the selected option.
  static String select(
    String message,
    List<String> options, {
    bool isRequired = false,
  }) {
    stdout.writeln('\n\n$message\n');
    for (var i = 0; i < options.length; i++) {
      stdout.writeln("  [${i + 1}]. ${options[i]}");
    }

    var res = read("Enter the number of the option:");
    var num = int.tryParse(res);
    if ((num == null || num < 1 || num > options.length) && isRequired) {
      write("Invalid option!", CappColors.error);
      return select(message, options, isRequired: isRequired);
    }

    return num != null && options.length > num - 1 ? options[num - 1] : '';
  }

  /// [yesNo] method is used to ask a question that has a yes or no answer.
  /// The [message] is the message that will be shown in the console.
  /// The method returns a boolean value.
  /// If the answer is yes, it returns true.
  static bool yesNo(String message) {
    var res = read("$message (y/n):");
    if (res.toLowerCase() == 'yes' || res.toLowerCase() == 'y') {
      return true;
    } else if (res.toLowerCase() == 'no' || res.toLowerCase() == 'n') {
      return false;
    } else {
      write("Invalid option!", CappColors.error);
      return yesNo(message);
    }
  }

  /// [writeTable] method is used to print a table in the console.
  /// The [data] is the list of lists of strings that will be shown in the table.
  /// The [dubleBorder] is a boolean that indicates if the table has a double border or not.
  /// The [color] is the color of the table.
  static void writeTable(
    List<List<String>> data, {
    bool dubleBorder = false,
    CappColors color = CappColors.error,
  }) {
    String res = '';
    String set = dubleBorder ? "═║╔╦╗╠╬╣╚╩╝" : "─│┌┬┐├┼┤└┴┘";
    List<int> columnWidths = List.filled(data[0].length, 0);
    for (var row in data) {
      for (int i = 0; i < row.length; i++) {
        columnWidths[i] =
            row[i].length > columnWidths[i] ? row[i].length : columnWidths[i];
      }
    }

    res += _printBorder(columnWidths, set[2], set[4], false, true, set);

    for (var i = 0; i < data.length; i++) {
      StringBuffer buffer = StringBuffer();
      buffer.write(set[1]);
      for (int j = 0; j < data[i].length; j++) {
        var cell = (i == 0)
            ? data[i][j]
                .padLeft((columnWidths[j] + data[i][j].length) ~/ 2)
                .padRight((columnWidths[j]))
            : data[i][j].padRight(columnWidths[j]);
        buffer.write(" " + cell + " ");
        buffer.write(set[1]);
      }
      res += buffer.toString() + '\n';

      if (i < data.length - 1) {
        if (columnWidths.length - 2 != i) {
          res += _printBorder(columnWidths, set[5], set[7], false, false, set);
        } else {
          res += _printBorder(columnWidths, set[5], set[7], false, false, set);
        }
      }
    }

    res += _printBorder(columnWidths, set[8], set[10], true, false, set);
    write(res, color);
  }

  static String _printBorder(
    List<int> columnWidths,
    String leftChar,
    String rightChar,
    bool isLast,
    bool isFirst,
    String set,
  ) {
    StringBuffer border = StringBuffer();
    border.write(leftChar);
    int i = 0;
    for (int width in columnWidths) {
      i++;
      border.write(set[0] * (width + 2));
      if (i != columnWidths.length) {
        if (isFirst) {
          border.write(set[3]);
        } else if (isLast) {
          border.write(set[9]);
        } else {
          border.write(set[6]);
        }
      }
    }
    border.writeln(rightChar);
    return border.toString();
  }

  static List<String> readMultiChoice(
    String message,
    List<String> options, {
    List<String> selected = const [],
    CappColors color = CappColors.none,
    bool required = false,
  }) {
    int selectedIndex = 0;
    List<bool> checked = List.filled(options.length, false);
    for (var i = 0; i < options.length; i++) {
      var option = options[i];
      checked[i] = selected.contains(option);
    }

    void render([int input = -1]) {
      // Clear the console
      clear();
      write(message, CappColors.info, true);

      for (var i = 0; i < options.length; i++) {
        final checkbox = checked[i] ? '[x]' : '[ ]';
        final prefix = (i == selectedIndex) ? '> ' : '  ';
        if ((i == selectedIndex)) {
          write('$prefix$checkbox ${options[i]}', color);
        } else {
          write('$prefix$checkbox ${options[i]}', CappColors.none);
        }
      }
      write(
        '\n\nUse Arrow Keys to navigate, Space to toggle, Enter to confirm.',
        color,
      );
    }

    render();

    stdin.lineMode = false;
    stdin.echoMode = false;

    try {
      while (true) {
        var input = stdin.readByteSync();

        if (input == 27) {
          // Arrow key sequence starts with ESC (27)
          var next1 = stdin.readByteSync();
          var next2 = stdin.readByteSync();

          if (next1 == 91) {
            if (next2 == 65) {
              // Arrow Up
              selectedIndex = (selectedIndex - 1) % options.length;
              if (selectedIndex < 0) selectedIndex += options.length;
            } else if (next2 == 66) {
              // Arrow Down
              selectedIndex = (selectedIndex + 1) % options.length;
            }
          }
        } else if (input == 32) {
          // Space key
          checked[selectedIndex] = !checked[selectedIndex];
        } else if (input == 13 || input == 10) {
          // Enter key
          break;
        }

        render(input);
      }
    } finally {
      stdin.lineMode = true;
      stdin.echoMode = true;
    }

    var res = [
      for (var i = 0; i < options.length; i++)
        if (checked[i]) options[i]
    ];
    if (required && res.isEmpty) {
      return readMultiChoice(
        message + "\n\n * At least one option is required!",
        options,
        selected: [],
        color: color,
        required: required,
      );
    }

    return res;
  }
}

/// [CappColors] is an enum that contains the colors that can be used in the console.
/// The colors are none, warning, error, success, info, and off.
enum CappColors {
  none,
  warnnig,
  error,
  success,
  info,
  off,
}

/// [CappProgressType] is an enum that contains three types of progress widgets.
/// The types are spinner, bar, timer, and circle.
enum CappProgressType {
  spinner,
  bar,
  circle,
  timer,
}
