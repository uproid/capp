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
    'Progress timer',
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
  if (select == 'Progress circle') {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.circle,
    );
  }
  // Progress bar
  else if (select == 'Progress bar') {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.bar,
    );
  }
  // Progress spinner
  else if (select == 'Progress spinner') {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.spinner,
    );
  }
  else if (select == 'Progress timer') {
    await CappConsole.progress(
      'I am waiting here for 5 secounds!',
      () async => Future.delayed(Duration(seconds: 5)),
      type: CappProgressType.timer,
    );
  }
  // Yes/No Questions
  else if (select == 'Yes/No questions') {
    final res = await CappConsole.yesNo('Do you agree? ');
    CappConsole.write(
      "Your answer is ${res ? 'YES' : 'NO'}",
      CappColors.warnnig,
    );
  }
  // Input text
  else if (select == 'Input text') {
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
  else if (select == 'Make a table') {
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
  else if (select == 'Clear screen') {
    CappConsole.clear();
  }

  // Help
  else if (select == 'Help') {
    CappConsole.write(c.manager.getHelp());
  } else if (select == options.last) {
    return CappConsole('Exit!');
  }

  return test(c);
}
