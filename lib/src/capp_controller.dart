import 'capp_manager.dart';
import 'capp_option.dart';
import 'capp_console.dart';

/// [CappController] is a class that represents a controller in the console application.
/// The controller is a class that contains the main logic of the application.
/// The controller can have options that can be passed to the controller from the console.
class CappController {
  /// The name of the controller it will be used to call the controller from the console.
  /// For example, if the name is 'test' then the controller can be called by typing 'test' in the console. `$ webapp test`
  /// The name should be unique in the application.
  String name;

  /// The description of the controller it will be shown in the help command.
  String description;

  /// The manager of the controller it will be used to access the manager methods and properties.
  /// CappManager is mainly used to run the application.
  late CappManager manager;

  /// The options of the controller it will be used to pass the options to the controller from the console.
  /// The options can be passed to the controller by typing the option name and the value.
  /// It can be a short name or a full name.
  /// For example, if the option name is 'help' then it can be passed by typing '--help' or '-h'.
  /// The options can be required or not.
  /// The options can be have value with this format '--option value' or '-o value'.
  List<CappOption> options = [];
  Future<CappConsole> Function(CappController args) run;

  /// The constructor of the CappController class.
  CappController(
    this.name, {
    this.description = '',
    required this.options,
    required this.run,
  });

  /// The [init] method is used to initialize the controller.
  init({required CappManager manager}) {
    this.manager = manager;
  }

  /// The [getOption] method is used to get the value of the option by the option name.
  String getOption(String name, {String def = ''}) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.value.isEmpty ? def : option.value;
      }
    }
    return def;
  }

  /// The [existsOption] method is used to check if the option exists in the controller or not.
  bool existsOption(String name) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.existsInArgs;
      }
    }
    return false;
  }
}
