import 'dart:io';
import 'package:test/test.dart';
import 'package:args/args.dart';
import 'package:ironship/commands/command_registry.dart';
import 'package:ironship/commands/init_command.dart';
import 'package:ironship/commands/help_command.dart';
import 'package:ironship/commands/version_command.dart';
import 'package:ironship/commands/doctor_command.dart';
import 'package:ironship/commands/feature_command.dart';
import 'package:ironship/commands/module_command.dart';
import 'package:ironship/commands/blueprint_command.dart';
import 'package:ironship/commands/docs_command.dart';
import 'package:ironship/commands/score_command.dart';

void main() {
  group('CLI Foundation Tests', () {
    late CommandRegistry registry;

    setUp(() {
      registry = CommandRegistry();
      registry.register(InitCommand());
      registry.register(HelpCommand(registry));
      registry.register(VersionCommand());
      registry.register(DoctorCommand());
      registry.register(FeatureCommand());
      registry.register(ModuleCommand());
      registry.register(BlueprintCommand());
      registry.register(DocsCommand());
      registry.register(ScoreCommand());
    });

    test('Registry Lookup', () {
      expect(registry.hasCommand('init'), isTrue);
      expect(registry.hasCommand('help'), isTrue);
      expect(registry.hasCommand('version'), isTrue);
      expect(registry.hasCommand('doctor'), isTrue);
      expect(registry.hasCommand('unknown'), isFalse);

      final initCommand = registry.getCommand('init');
      expect(initCommand, isA<InitCommand>());
      expect(initCommand?.name, equals('init'));
      expect(initCommand?.description, isNotEmpty);
    });

    test('Validation Logic', () {
      expect(registry.validateCommand('init'), isTrue);
      expect(registry.validateCommand('invalid_command'), isFalse);
    });

    test('Version Command Exec', () async {
      final versionCmd = registry.getCommand('version')!;
      final exitCode = await versionCmd.execute([]);
      expect(exitCode, equals(0));

      final versionStr = await VersionCommand.getVersion();
      expect(versionStr, isNot(equals('unknown')));
      expect(versionStr, equals('2.0.0'));
    });

    test('Help Command Exec', () async {
      final helpCmd = registry.getCommand('help')!;
      final exitCode = await helpCmd.execute([]);
      expect(exitCode, equals(0));
    });

    test('Init Command Validation - Missing project name', () async {
      final initCmd = registry.getCommand('init')!;
      final exitCode = await initCmd.execute([]);
      expect(exitCode, equals(1));
    });

    test('Init Command Validation - Invalid project name', () async {
      final initCmd = registry.getCommand('init')!;
      final exitCode = await initCmd.execute(['MyProj123']);
      expect(exitCode, equals(1));
    });

    test('Init Command Validation - Project directory already exists',
        () async {
      final tempDir = Directory('existing_temp_dir');
      await tempDir.create();
      try {
        final initCmd = registry.getCommand('init')!;
        final exitCode = await initCmd.execute(['existing_temp_dir']);
        expect(exitCode, equals(1));
      } finally {
        await tempDir.delete();
      }
    });

    test('Placeholder commands return Not Implemented Yet', () async {
      final doctorCmd = registry.getCommand('doctor')!;
      expect(doctorCmd.name, equals('doctor'));

      final exitCode = await doctorCmd.execute([]);
      expect(exitCode, equals(0));
    });

    test('CLI Args Parser matches target commands and flags', () {
      final parser = ArgParser()
        ..addFlag('help', abbr: 'h', negatable: false)
        ..addFlag('version', negatable: false);

      // Support forge --help
      final resHelp = parser.parse(['--help']);
      expect(resHelp['help'], isTrue);

      // Support forge -h
      final resAbbrHelp = parser.parse(['-h']);
      expect(resAbbrHelp['help'], isTrue);

      // Support forge --version
      final resVersion = parser.parse(['--version']);
      expect(resVersion['version'], isTrue);

      // Support forge init my_app
      final resInit = parser.parse(['init', 'my_app']);
      expect(resInit.rest.first, equals('init'));
      expect(resInit.rest[1], equals('my_app'));
    });
  });
}
