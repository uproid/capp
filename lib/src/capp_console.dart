import 'dart:io';

class CappConsole {
  dynamic output;
  CappColors color;
  bool space;

  CappConsole(this.output, [this.color = CappColors.info, this.space = false]);
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

  static write(dynamic obj,
      [CappColors color = CappColors.none, space = false]) {
    CappConsole("${space ? '\n\n' : ''}$obj${space ? '\n\n' : ''}", color)
        .log();
  }

  static void clear() {
    if (Platform.isWindows) {
      Process.runSync('cls', [], runInShell: true);
    } else {
      stdout.write('\x1B[2J\x1B[0;0H');
    }
  }

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

  static Future<T> progress<T>(
    String message,
    Future<T> Function() action, {
    CappProgressType type = CappProgressType.bar,
  }) async {
    bool isLoading = true;
    bool isWindows = Platform.isWindows;

    Future<void> showSpinner() async {
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
        stdin.echoMode = false;
        stdin.lineMode = false;
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
        stdin.echoMode = true;
        stdin.lineMode = true;
      }
      isLoading = false;
      await spinnerFuture;
      stdout.write('\r$message\t\tDone!                            \n');
    }
  }

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

    res += printBorder(columnWidths, set[2], set[4], false, true, set);

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
          res += printBorder(columnWidths, set[5], set[7], false, false, set);
        } else {
          res += printBorder(columnWidths, set[5], set[7], false, false, set);
        }
      }
    }

    res += printBorder(columnWidths, set[8], set[10], true, false, set);
    write(res, color);
  }

  static String printBorder(
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
}

enum CappColors {
  none,
  warnnig,
  error,
  success,
  info,
  off,
}

enum CappProgressType {
  spinner,
  bar,
  circle,
}
