import 'package:test/test.dart';
import 'package:capp/capp.dart';
import 'dart:async';
import 'dart:io';

void main() {
  group('CappManager Tests', () {
    test('Process simple command', () async {
      bool testRun = false;
      var capp = CappManager(
        main: CappController('main',
            options: [], run: (c) async => CappConsole.empty),
        args: ['test'],
        controllers: [
          CappController('test', options: [], run: (c) async {
            testRun = true;
            return CappConsole.empty;
          })
        ],
      );
      await capp.process();
      expect(testRun, isTrue);
    });

    test('Option Parsing - short name and long name', () async {
      String? optionValue;
      bool? optionExists;

      var controller = CappController('test', options: [
        CappOption(
            name: 'print',
            shortName: 'p',
            description: 'print option',
            value: 'default')
      ], run: (c) async {
        optionValue = c.getOption('print');
        optionExists = c.existsOption('print');
        return CappConsole.empty;
      });

      var capp = CappManager(
        main: CappController('main',
            options: [], run: (c) async => CappConsole.empty),
        args: ['test', '--print', 'hello'],
        controllers: [controller],
      );
      await capp.process();
      expect(optionValue, equals('hello'));
      expect(optionExists, isTrue);

      capp.args = ['test', '-p', 'world'];
      await capp.process();
      expect(optionValue, equals('world'));
      expect(optionExists, isTrue);

      capp.args = ['test', '--print=equalValue'];
      await capp.process();
      expect(optionValue, equals('equalValue'));
      expect(optionExists, isTrue);
    });

    test('Main controller fallback', () async {
      bool mainRun = false;
      var capp = CappManager(
        main: CappController('main', options: [], run: (c) async {
          mainRun = true;
          return CappConsole.empty;
        }),
        args: ['unknown_command'],
        controllers: [],
      );
      await capp.process();
      expect(mainRun, isTrue);
    });

    test('onSelect Option logic', () async {
      bool onSelectTriggered = false;
      var capp = CappManager(
        main: CappController('main',
            options: [], run: (c) async => CappConsole.empty),
        args: ['test', '--help'],
        controllers: [
          CappController('test', options: [
            CappOption(
                name: 'help',
                shortName: 'h',
                description: 'help',
                onSelect: (c) {
                  onSelectTriggered = true;
                  return false; // Stop execution
                })
          ], run: (c) async {
            throw Exception('Should not run');
          })
        ],
      );
      await capp.process();
      expect(onSelectTriggered, isTrue);
    });

    test('Help generation', () {
      var capp = CappManager(
        main: CappController('main',
            options: [],
            description: 'Main App',
            run: (c) async => CappConsole.empty),
        args: [],
        controllers: [
          CappController('test',
              description: 'Test command',
              options: [
                CappOption(
                    name: 'verbose',
                    shortName: 'v',
                    description: 'Verbose mode')
              ],
              run: (c) async => CappConsole.empty)
        ],
      );
      var helpText = capp.getHelp();
      expect(helpText.contains('Test command'), isTrue);
      expect(helpText.contains('--verbose'), isTrue);
    });

    test('History management', () async {
      var capp = CappManager(
        main: CappController('main',
            options: [], run: (c) async => CappConsole.empty),
        args: ['test'],
        controllers: [
          CappController('test',
              options: [], run: (c) async => CappConsole.empty)
        ],
      );

      await capp.process();
      expect(capp.history.length, 1);
      expect(capp.history.first, ['test']);

      capp.args = ['test2'];
      await capp.process();
      expect(capp.history.length, 2);
      expect(capp.history.last, ['test2']);
    });
  });

  group('CappConsole Tests', () {
    test('Console properties check', () {
      var console = CappConsole('hello world', CappColors.success, true);
      expect(console.output, 'hello world');
      expect(console.color, CappColors.success);
      expect(console.space, true);
    });

    test('Console empty instance', () {
      var empty = CappConsole.empty;
      expect(empty.output, '');
      expect(empty.color, CappColors.info);
    });

    test('Console setActiveBuffer and clearActiveBuffer', () {
      var buffer = StringBuffer();
      CappConsole.setActiveBuffer(buffer, 'App> ');

      CappConsole.addToCommandBar('hello');
      expect(buffer.toString(), 'hello');

      CappConsole
          .removeCommandBar(); // will write over it, and clear buffer internally
      expect(buffer.isEmpty, isTrue);

      CappConsole.clearActiveBuffer();
    });

    test('Write methods should return current instance', () {
      var console = CappConsole.write('msg', CappColors.warning, false);
      expect(console, isA<CappConsole>());
      expect(console.output, contains('msg'));
    });

    test('Table creation check logic (integration check without crashing)', () {
      var console = CappConsole.writeTable([
        ['ID', 'Name'],
        ['1', 'Test User']
      ], dubleBorder: true, color: CappColors.success);
      expect(console, isA<CappConsole>());
    });

    test('JSON serialization', () {
      var data = {'key': 'value'};
      var console =
          CappConsole.writeJson(data, pretty: true, color: CappColors.info);
      expect(console.output, contains('"key": "value"'));
    });
  });

  group('CappOption Tests', () {
    test('Reset value logic', () {
      var option =
          CappOption(name: 'test', shortName: 't', description: 'test');
      option.value = 'changed';
      option.existsInArgs = true;

      option.resetValue();
      expect(option.value, '');
      expect(option.existsInArgs, false);
    });

    test('Hide in help flag', () {
      var option = CappOption(
          name: 'hidden', shortName: 'h', description: '', hideInHelp: true);
      expect(option.hideInHelp, isTrue);
    });
  });
}
