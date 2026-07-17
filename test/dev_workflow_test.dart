import 'dart:io';
import 'package:test/test.dart';
import '../tool/dev_workflow.dart';

class MockProcessRunner implements ProcessRunner {
  final Map<String, ProcessResult> responses = {};
  final List<List<String>> calls = [];

  void mockResponse(
      String executable, List<String> args, ProcessResult result) {
    responses['$executable ${args.join(" ")}'] = result;
  }

  @override
  Future<ProcessResult> run(String executable, List<String> arguments) async {
    calls.add([executable, ...arguments]);
    final key = '$executable ${arguments.join(" ")}';
    if (responses.containsKey(key)) {
      return responses[key]!;
    }
    // Fallback default successful response
    return ProcessResult(0, 0, '', '');
  }
}

void main() {
  group('Developer Workflow Automation CLI Tests', () {
    late MockProcessRunner mockRunner;
    late DevWorkflowCli cli;

    setUp(() {
      mockRunner = MockProcessRunner();
      cli = DevWorkflowCli(runner: mockRunner);
    });

    test('branch command - creates and checks out branch', () async {
      mockRunner.mockResponse(
        'git',
        ['branch', '--list', 'feature/33-ironship-config'],
        ProcessResult(0, 0, '', ''), // Empty list = branch doesn't exist
      );
      mockRunner.mockResponse(
        'git',
        ['checkout', '-b', 'feature/33-ironship-config'],
        ProcessResult(0, 0, 'Switched to branch', ''),
      );

      final exitCode =
          await cli.runCommand(['branch', '33', 'ironship-config']);
      expect(exitCode, equals(0));
      expect(
          mockRunner.calls, contains(contains('feature/33-ironship-config')));
    });

    test('branch command - fails if branch already exists', () async {
      mockRunner.mockResponse(
        'git',
        ['branch', '--list', 'feature/33-ironship-config'],
        ProcessResult(0, 0, '  feature/33-ironship-config', ''), // Exists
      );

      final exitCode =
          await cli.runCommand(['branch', '33', 'ironship-config']);
      expect(exitCode, equals(1));
    });

    test('branch command - formats slug with invalid characters', () async {
      mockRunner.mockResponse(
        'git',
        ['branch', '--list', 'feature/33-ironship-config-engine'],
        ProcessResult(0, 0, '', ''),
      );
      mockRunner.mockResponse(
        'git',
        ['checkout', '-b', 'feature/33-ironship-config-engine'],
        ProcessResult(0, 0, '', ''),
      );

      final exitCode =
          await cli.runCommand(['branch', '33', 'Ironship Config Engine!!!']);
      expect(exitCode, equals(0));
    });

    test('commit command - fails if on main branch', () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'main', ''),
      );

      final exitCode = await cli.runCommand([
        'commit',
        '--type',
        'feat',
        '--scope',
        'config',
        '--issue',
        '33',
        '--message',
        'impl config engine'
      ]);

      expect(exitCode, equals(1));
    });

    test('commit command - fails if working tree is clean', () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'feature/33-config', ''),
      );
      mockRunner.mockResponse(
        'git',
        ['status', '--porcelain'],
        ProcessResult(0, 0, '', ''), // clean
      );

      final exitCode = await cli.runCommand([
        'commit',
        '--type',
        'feat',
        '--issue',
        '33',
        '--message',
        'message'
      ]);

      expect(exitCode, equals(1));
    });

    test('commit command - stages and commits changes successfully', () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'feature/33-config', ''),
      );
      mockRunner.mockResponse(
        'git',
        ['status', '--porcelain'],
        ProcessResult(0, 0, ' M lib/main.dart', ''), // dirty
      );
      mockRunner.mockResponse(
        'git',
        ['add', '.'],
        ProcessResult(0, 0, '', ''),
      );
      mockRunner.mockResponse(
        'git',
        ['commit', '-m', 'feat(config): impl config (#33)'],
        ProcessResult(0, 0, '1 file changed', ''),
      );

      final exitCode = await cli.runCommand([
        'commit',
        '--type',
        'feat',
        '--scope',
        'config',
        '--issue',
        '33',
        '--message',
        'impl config'
      ]);

      expect(exitCode, equals(0));
      final hasCommitCall = mockRunner.calls.any((call) =>
          call.length >= 4 &&
          call[0] == 'git' &&
          call[1] == 'commit' &&
          call[2] == '-m' &&
          call[3] == 'feat(config): impl config (#33)');
      expect(hasCommitCall, isTrue);
    });

    test('push command - pushes current branch', () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'feature/33-config', ''),
      );
      mockRunner.mockResponse(
        'git',
        ['push', '-u', 'origin', 'feature/33-config'],
        ProcessResult(0, 0, 'pushed', ''),
      );

      final exitCode = await cli.runCommand(['push']);
      expect(exitCode, equals(0));
    });

    test('pr command - uses gh if installed', () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'feature/33-config', ''),
      );
      mockRunner.mockResponse(
        'gh',
        ['--version'],
        ProcessResult(0, 0, 'gh version 2.0.0', ''),
      );
      mockRunner.mockResponse(
        'gh',
        [
          'pr',
          'create',
          '--base',
          'main',
          '--head',
          'feature/33-config',
          '--title',
          'Impl config',
          '--body',
          '## Summary\n\nImpl config\n\n## Testing\n\n- dart analyze\n- dart test\n\nCloses #33'
        ],
        ProcessResult(0, 0, 'https://github.com/PR', ''),
      );

      final exitCode = await cli
          .runCommand(['pr', '--issue', '33', '--title', 'Impl config']);

      expect(exitCode, equals(0));
    });

    test('pr command - outputs PR template if gh cli is not installed',
        () async {
      mockRunner.mockResponse(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        ProcessResult(0, 0, 'feature/33-config', ''),
      );
      mockRunner.mockResponse(
        'gh',
        ['--version'],
        ProcessResult(1, 127, '', 'command not found'), // not installed
      );

      final exitCode = await cli
          .runCommand(['pr', '--issue', '33', '--title', 'Impl config']);

      expect(exitCode, equals(0));
    });
  });
}
