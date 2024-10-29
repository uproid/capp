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

Future<CappConsole> test(CappController c) async {
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
      ['3', 'Arian', '33', 'Frankfort0', 'Taxi driver']
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
