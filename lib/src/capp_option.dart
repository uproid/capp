import 'package:capp/capp.dart';

typedef bool CaptionEvent(CappController controller);

/// CappOption class is a class that represents an option in the console application.
class CappOption {
  /// The name of the option it will be used to call the option from the console.
  /// For example, if the name is 'help' then the option can be called by typing '--help' in the console.
  String name;

  /// The short name of the option it will be used to call the option from the console.
  /// For example, if the short name is 'h' then the option can be called by typing '-h' in the console.
  String shortName;

  /// The description of the option it will be shown in the help command.
  /// The description should be clear and concise.
  /// The description will be shown in the help command.
  String description;

  /// The value of the option it will be used to store the value of the option.
  /// The value can be empty or have a value.
  String value;

  /// [existsInArgs] is a boolean value that represents if the option exists in the arguments or not.
  bool existsInArgs = false;

  /// [hideInHelp] is a boolean value that represents if the option should be hidden in the help command or not.
  bool hideInHelp;

  /// The [CappOption] constructor is used to create an instance of the [CappOption] class.
  CaptionEvent? onSelect;

  /// The constructor of the CappOption class.
  /// The [name] is the name of the option.
  /// The [description] is the description of the option.
  /// The [value] is the value of the option.
  /// The [shortName] is the short name of the option.
  CappOption({
    required this.name,
    this.description = '',
    this.value = '',
    this.shortName = '',
    this.hideInHelp = false,
    this.onSelect,
  });
}
