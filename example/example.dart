import 'package:capp/capp.dart';

void main(
    [List<String> args = const [
      "test",
    ]]) async {
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
          CappConsole.write("You entered: $name", CappColors.warnnig);

          CappConsole.writeTable(
            [
              ['#', 'A', 'B', 'C'],
              ['1', 'Name', 'Age', 'City'],
              ['2', 'Alice', '30', 'New York'],
              ['3', 'Bobas', '25', 'Los'],
              ['4', 'Charlie', '28', 'Chicago'],
            ],
            color: CappColors.warnnig,
          );

          var res3 = CappConsole.yesNo("Do you want to continue?");
          CappConsole.write("You answer is: $res3", CappColors.error);

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

          await CappConsole.progress(
            "I am waiting here for 5 seconds",
            () async => {
              await Future.delayed(Duration(seconds: 5)),
            },
            type: CappProgressType.circle,
          );

          await CappConsole.progress(
            "I am waiting here for 5 seconds",
            () async => {
              await Future.delayed(Duration(seconds: 5)),
            },
            type: CappProgressType.spinner,
          );

          return CappConsole("TEST");
        },
      )
    ],
  );

  cmdManager.process();
}
