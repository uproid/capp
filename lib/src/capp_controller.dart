import 'capp_manager.dart';
import 'capp_option.dart';
import 'capp_console.dart';

class CappController {
  String name;
  String description;
  late CappManager manager;

  List<CappOption> options = [];
  Future<CappConsole> Function(CappController args) run;

  CappController(
    this.name, {
    this.description = '',
    required this.options,
    required this.run,
  });

  init({required CappManager manager}) {
    this.manager = manager;
  }

  String getOption(String name, {String def = ''}) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.value.isEmpty ? def : option.value;
      }
    }
    return def;
  }

  bool existsOption(String name) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.existsInArgs;
      }
    }
    return false;
  }
}
