# Capp - Console Application Package
[![pub package](https://img.shields.io/pub/v/capp.svg)](https://pub.dev/packages/capp)
[![Dev](https://img.shields.io/pub/v/capp.svg?label=dev&include_prereleases)](https://pub.dev/packages/capp)
[![Donate](https://img.shields.io/badge/Support-Donate-pink.svg)](https://buymeacoffee.com/fardziao)

`Capp` is a powerful Dart package designed to simplify the development of interactive console applications with features for handling user inputs, generating help information, managing arguments, and creating visually structured outputs like tables and progress indicators.

## Features

- **Argument and Option Management**: Define and manage command-line arguments and options easily.
- **User Input Handling**: Supports reading user inputs with prompts and selection options.
- **Structured Output**: Display tables, messages in color, and various progress indicators in the console.
- **Help Generation**: Automatically generate a help guide for your console commands and options.

## Getting Started

1. Add `capp` to your `pubspec.yaml`.
2. Import `package:capp/capp.dart`.
3. Create commands, options, and user inputs to build your interactive console application.

## Example Usage

```dart
import "package:capp/capp.dart";

void main([
  List<String> args = const [],
]) {
  var app = CappManager(
    main: CappController(
      '',
      options: [
        CappOption(
          name: 'help',
          shortName: 'h',
          description: 'Show help',
        ),
      ],
      run: (c) async {
        if (c.existsOption('help')) {
          return CappConsole(c.manager.getHelp());
        } else {
          return test(c);
        }
      },
    ),
    args: args,
    controllers: [
      CappController(
        'test',
        options: [],
        run: test,
      ),
    ],
  );

  app.process();
}

Future<CappConsole> test(c) async {
  const options = [
    'Progress circle',
    'Progress bar',
    'Progress spinner',
    'Yes/No questions',
    'Input text',
    'Make a table',
    'Clear screen',
    'Help',
    'Exit',
  ];
  var select = CappConsole.select(
    'Select an option to test Widgets of console:',
    options,
  );
  CappConsole.write('Your selection is: $select', CappColors.success);

  // Progress circle
  if (select == options[0]) {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.circle,
    );
  }
  // Progress bar
  else if (select == options[1]) {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.bar,
    );
  }
  // Progress spinner
  else if (select == options[2]) {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.spinner,
    );
  }
  // Yes/No Questions
  else if (select == options[3]) {
    final res = await CappConsole.yesNo('Do you agree? ');
    CappConsole.write(
      "Your answer is ${res ? 'YES' : 'NO'}",
      CappColors.warnnig,
    );
  }
  // Input text
  else if (select == options[4]) {
    var age = CappConsole.read(
      'What is your age?',
      isRequired: true,
      isNumber: true,
    );

    CappConsole.write(
      "Your age is: $age",
      CappColors.success,
    );
  }
  // Make a table
  else if (select == options[5]) {
    const table = [
      ['#', 'Name', 'Age', 'City', 'Job'],
      ['1', 'Farhad', '38', 'Amsterdam', 'Engineer'],
      ['2', 'Adrian', '25', 'Berlin', 'Teacher'],
      ['3', 'Arian', '33', 'Frankfort', 'Taxi driver']
    ];

    CappConsole.writeTable(table);

    CappConsole.writeTable(
      table,
      color: CappColors.warnnig,
      dubleBorder: true,
    );
  }
  // Clear Screen
  else if (select == options[6]) {
    CappConsole.clear();
  }
  // Help
  else if (select == options[7]) {
    CappConsole.write(c.manager.getHelp());
  } else if (select == options.last) {
    return CappConsole('Exit!');
  }

  return test(c);
}
```

## Example Output

```shell
$ dart ./example/example.dart


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 1
Your selection is: Progress circle
I am waiting here for 5 secounds!               ⢿                            


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 2
Your selection is: Progress bar
I am waiting here for 5 secounds! █████░████████                            


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 3
Your selection is: Progress spinner
I am waiting here for 5 secounds! |----->-------|                          


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 4
Your selection is: Yes/No questions


Do you agree?  (y/n): N
Your answer is NO


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 5
Your selection is: Input text


What is your age? 33
Your age is: 33


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 5
Your selection is: Input text


What is your age? 33
Your age is: 33


Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 6
Your selection is: Make a table
┌───┬────────┬─────┬────────────┬─────────────┐
│ # │  Name  │ Age │    City    │     Job     │
├───┼────────┼─────┼────────────┼─────────────┤
│ 1 │ Farhad │ 38  │ Amsterdam  │ Engineer    │
├───┼────────┼─────┼────────────┼─────────────┤
│ 2 │ Adrian │ 25  │ Berlin     │ Teacher     │
├───┼────────┼─────┼────────────┼─────────────┤
│ 3 │ Arian  │ 33  │ Frankfort │ Taxi driver │
└───┴────────┴─────┴────────────┴─────────────┘

╔═══╦════════╦═════╦════════════╦═════════════╗
║ # ║  Name  ║ Age ║    City    ║     Job     ║
╠═══╬════════╬═════╬════════════╬═════════════╣
║ 1 ║ Farhad ║ 38  ║ Amsterdam  ║ Engineer    ║
╠═══╬════════╬═════╬════════════╬═════════════╣
║ 2 ║ Adrian ║ 25  ║ Berlin     ║ Teacher     ║
╠═══╬════════╬═════╬════════════╬═════════════╣
║ 3 ║ Arian  ║ 33  ║ Frankfort ║ Taxi driver ║
╚═══╩════════╩═════╩════════════╩═════════════╝



Select an option to test Widgets of console:

  [1]. Progress circle
  [2]. Progress bar
  [3]. Progress spinner
  [4]. Yes/No questions
  [5]. Input text
  [6]. Make a table
  [7]. Clear screen
  [8]. Help
  [9]. Exit


Enter the number of the option: 8
Your selection is: Help
Available commands:
1) test:
──────────────────────────────


      --help    Show help
      -h
──────────────────────────────
```