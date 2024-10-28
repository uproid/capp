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
import 'package:capp/capp.dart';

void main([List<String> args = const ["test"]]) async {
  CappManager cmdManager = CappManager(
    args: args,
    main: CappController(
      'help',
      options: [],
      run: (c) async => CappConsole(c.manager.getHelp()),
    ),
    controllers: [
      CappController(
        'test',
        options: [
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of user',
          ),
        ],
        run: (controller) async {
          var name = controller.getOption('name', def: '');
          if (name.isEmpty) {
            name = CappConsole.read("Enter your name:");
          }
          CappConsole.write("You entered: $name", CappColors.warning);

          CappConsole.writeTable(
            [
              ['#', 'A', 'B', 'C'],
              ['1', 'Name', 'Age', 'City'],
              ['2', 'Alice', '30', 'New York'],
              ['3', 'Bobas', '48', 'Amsterdam'],
              ['4', 'Charlie', '28', 'Chicago'],
            ],
            color: CappColors.warning,
          );

          var res3 = CappConsole.yesNo("Do you want to continue?");
          CappConsole.write("Your answer is: $res3", CappColors.error);

          var res = CappConsole.select(
            "Do you want to continue?",
            [
              "Option 1",
              "Option 2",
              "Option 3",
              "Option 4",
              "Option 5",
              "Option 6",
              "Option 7",
              "Option 8",
              "Option 9",
              "Option 10",
            ],
          );
          CappConsole.write("You selected: $res", CappColors.success);

          await CappConsole.progress(
            "I am waiting here for 5 seconds",
            () async => {
              await Future.delayed(Duration(seconds: 5)),
            },
            type: CappProgressType.bar,
          );

          return CappConsole("Process finished!");
        },
      )
    ],
  );

  cmdManager.process();
}
```

## Example Output

```shell
$ dart example/example.dart test

Enter your name: Uproid
You entered: Uproid
┌───┬────────────────────┬────────────┬────────────────────────────────┐
│ # │         A          │     B      │               C                │
├───┼────────────────────┼────────────┼────────────────────────────────┤
│ 1 │ Name               │ Age        │ City                           │
├───┼────────────────────┼────────────┼────────────────────────────────┤
│ 2 │ Alice              │ 30         │ New York                       │
├───┼────────────────────┼────────────┼────────────────────────────────┤
│ 3 │ Bobas              │ 48         │ Amsterdam                      │
├───┼────────────────────┼────────────┼────────────────────────────────┤
│ 4 │ Charlie            │ 28         │ Chicago                        │
└───┴────────────────────┴────────────┴────────────────────────────────┘

Do you want to continue? (y/n): y
Your answer is: true

Do you want to continue?

  [1]. Option 1
  [2]. Option 2
  [3]. Option 3
  [4]. Option 4
  [5]. Option 5
  [6]. Option 6
  [7]. Option 7
  [8]. Option 8
  [9]. Option 9
  [10]. Option 10

Enter the number of the option: 8
You selected: Option 8
I am waiting here for 5 seconds ████████████████████████████░█
I am waiting here for 5 seconds                 ⢿ 
I am waiting here for 5 seconds |----------------->------------|
```