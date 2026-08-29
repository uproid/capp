import 'dart:io';

class Cout {
  static List<CoutEvent> _onWrite = [];

  static void write(Object? object) {
    stdout.write(object);
    _onWrite.forEach((call) => call(object?.toString() ?? ''));
  }

  static void writeln([Object? object = ""]) {
    stdout.writeln(object);
    _onWrite.forEach((call) => call(object?.toString() ?? '\n'));
  }

  static int addOnWrite(CoutEvent event) {
    _onWrite.add(event);
    return _onWrite.indexOf(event);
  }

  static void removeOnWrite(CoutEvent event) {
    _onWrite.remove(event);
  }
}

typedef CoutEvent = void Function(String out);
