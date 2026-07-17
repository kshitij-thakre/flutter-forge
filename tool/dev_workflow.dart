import 'dart:io';
import 'package:args/args.dart';

abstract class ProcessRunner {
  Future<ProcessResult> run(String executable, List<String> arguments);
}

class SystemProcessRunner implements ProcessRunner {
  @override
  Future<ProcessResult> run(String executable, List<String> arguments) {
    return Process.run(executable, arguments);
  }
}

class DevWorkflowCli {
  final ProcessRunner runner;

  DevWorkflowCli({required this.runner});

  Future<int> runCommand(List<String> arguments) async {
    final parser = ArgParser();

    // Set up branch command parser
    final branchParser = ArgParser();

    // Set up commit command parser
    final commitParser = ArgParser()
      ..addOption('type',
          allowed: ['feat', 'fix', 'docs', 'test', 'refactor', 'chore'],
          help: 'Commit type (e.g., feat, fix).')
      ..addOption('scope', help: 'Commit scope (optional).')
      ..addOption('issue', help: 'Target issue number.')
      ..addOption('message', help: 'Commit message.');

    // Set up pr command parser
    final prParser = ArgParser()
      ..addOption('issue', help: 'Linked issue number.')
      ..addOption('title', help: 'Pull request title.');

    parser.addCommand('branch', branchParser);
    parser.addCommand('commit', commitParser);
    parser.addCommand('push');
    parser.addCommand('pr', prParser);

    ArgResults results;
    try {
      results = parser.parse(arguments);
    } catch (e) {
      print('Error parsing options: $e\n');
      _printUsage();
      return 1;
    }

    final command = results.command;
    if (command == null) {
      _printUsage();
      return 1;
    }

    try {
      switch (command.name) {
        case 'branch':
          return await _handleBranch(command.rest);
        case 'commit':
          return await _handleCommit(command);
        case 'push':
          return await _handlePush();
        case 'pr':
          return await _handlePr(command);
        default:
          _printUsage();
          return 1;
      }
    } catch (e) {
      print('Execution error: $e');
      return 1;
    }
  }

  Future<int> _handleBranch(List<String> args) async {
    if (args.length < 2) {
      print('Error: Missing issue number and slug.');
      print('Usage: dart run tool/dev_workflow branch <issue_number> <slug>');
      return 1;
    }

    final issueStr = args[0];
    final slug = args[1];

    final issueNum = int.tryParse(issueStr);
    if (issueNum == null) {
      print('Error: Issue number must be an integer.');
      return 1;
    }

    final slugRegex = RegExp(r'^[a-z0-9\-]+$');
    final formattedSlug =
        slug.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    if (formattedSlug.isEmpty || !slugRegex.hasMatch(formattedSlug)) {
      print(
          'Error: Invalid slug formatting. Slugs must contain alphanumeric characters and hyphens only.');
      return 1;
    }

    final branchName = 'feature/$issueNum-$formattedSlug';

    // Verify branch does not already exist
    final checkBranch =
        await runner.run('git', ['branch', '--list', branchName]);
    if (checkBranch.stdout.toString().trim().isNotEmpty) {
      print('Error: Branch "$branchName" already exists.');
      return 1;
    }

    print('Creating and checking out branch: $branchName...');
    final checkout = await runner.run('git', ['checkout', '-b', branchName]);
    if (checkout.exitCode != 0) {
      print('Error checking out branch: ${checkout.stderr}');
      return checkout.exitCode;
    }

    print('Switched to a new branch "$branchName".');
    return 0;
  }

  Future<int> _handleCommit(ArgResults options) async {
    final type = options['type'] as String?;
    final scope = options['scope'] as String?;
    final issueStr = options['issue'] as String?;
    final message = options['message'] as String?;

    if (type == null ||
        issueStr == null ||
        message == null ||
        message.trim().isEmpty) {
      print('Error: Missing required commit options.');
      print(
          'Usage: dart run tool/dev_workflow commit --type <type> [--scope <scope>] --issue <issue> --message "<message>"');
      return 1;
    }

    final issueNum = int.tryParse(issueStr);
    if (issueNum == null) {
      print('Error: Issue number must be an integer.');
      return 1;
    }

    // Safety checks
    final currentBranch = await _getCurrentBranch();
    if (currentBranch == 'main' || currentBranch == 'master') {
      print('Current branch is main.');
      print('Create a feature branch before continuing.');
      return 1;
    }

    if (!_isValidFeatureBranchName(currentBranch)) {
      print(
          'Warning: Current branch "$currentBranch" does not match feature branch convention (feature/<issue>-<slug>).');
    }

    // Check if working tree is clean
    final status = await runner.run('git', ['status', '--porcelain']);
    if (status.stdout.toString().trim().isEmpty) {
      print('Error: Working tree is clean. Nothing to commit.');
      return 1;
    }

    final commitMsg = scope != null && scope.isNotEmpty
        ? '$type($scope): $message (#$issueNum)'
        : '$type: $message (#$issueNum)';

    print('Staging all files...');
    final add = await runner.run('git', ['add', '.']);
    if (add.exitCode != 0) {
      print('Error staging files: ${add.stderr}');
      return add.exitCode;
    }

    print('Committing: "$commitMsg"...');
    final commit = await runner.run('git', ['commit', '-m', commitMsg]);
    if (commit.exitCode != 0) {
      print('Error committing changes: ${commit.stderr}');
      return commit.exitCode;
    }

    print('Successfully committed changes.');
    return 0;
  }

  Future<int> _handlePush() async {
    final currentBranch = await _getCurrentBranch();
    if (currentBranch == 'main' || currentBranch == 'master') {
      print('Current branch is main.');
      print('Create a feature branch before continuing.');
      return 1;
    }

    print('Pushing current branch "$currentBranch" to origin...');
    final push =
        await runner.run('git', ['push', '-u', 'origin', currentBranch]);
    if (push.exitCode != 0) {
      print('Error pushing changes: ${push.stderr}');
      return push.exitCode;
    }

    print('Successfully pushed "$currentBranch" to remote.');
    return 0;
  }

  Future<int> _handlePr(ArgResults options) async {
    final issueStr = options['issue'] as String?;
    final title = options['title'] as String?;

    if (issueStr == null || title == null || title.trim().isEmpty) {
      print('Error: Missing required PR options.');
      print(
          'Usage: dart run tool/dev_workflow pr --issue <issue> --title "<title>"');
      return 1;
    }

    final issueNum = int.tryParse(issueStr);
    if (issueNum == null) {
      print('Error: Issue number must be an integer.');
      return 1;
    }

    final currentBranch = await _getCurrentBranch();
    if (currentBranch == 'main' || currentBranch == 'master') {
      print('Current branch is main.');
      print('Create a feature branch before continuing.');
      return 1;
    }

    final prBody = _generatePrBody(title, issueNum);

    // Check if GitHub CLI is installed
    final hasGh = await _isGhCliInstalled();
    if (hasGh) {
      print('GitHub CLI detected. Creating Pull Request...');
      final prCreate = await runner.run('gh', [
        'pr',
        'create',
        '--base',
        'main',
        '--head',
        currentBranch,
        '--title',
        title,
        '--body',
        prBody,
      ]);
      if (prCreate.exitCode != 0) {
        print('Error creating PR via gh: ${prCreate.stderr}');
        return prCreate.exitCode;
      }
      print('PR created successfully!');
    } else {
      print('GitHub CLI is not installed.');
      print('==================================================');
      print('Generated PR Body (Copy and paste into GitHub UI):');
      print('==================================================');
      print('PR Title: $title\n');
      print(prBody);
      print('==================================================');
    }

    return 0;
  }

  Future<String> _getCurrentBranch() async {
    final res = await runner.run('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
    return res.stdout.toString().trim();
  }

  bool _isValidFeatureBranchName(String name) {
    return RegExp(r'^feature/\d+-[a-z0-9\-]+$').hasMatch(name);
  }

  Future<bool> _isGhCliInstalled() async {
    try {
      final res = await runner.run('gh', ['--version']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  String _generatePrBody(String title, int issueNum) {
    return '''## Summary

$title

## Testing

- dart analyze
- dart test

Closes #$issueNum''';
  }

  void _printUsage() {
    print('Ironship Developer Automation CLI\n');
    print('Usage: dart run tool/dev_workflow <command> [options]\n');
    print('Commands:');
    print(
        '  branch <issue> <slug>     Create and checkout a conventional feature branch.');
    print(
        '  commit [options]          Stage and commit conventional messages referencing issues.');
    print(
        '  push                      Push the active feature branch to remote origin.');
    print('  pr [options]              Submit or output linked Pull Requests.');
  }
}

void main(List<String> arguments) async {
  final cli = DevWorkflowCli(runner: SystemProcessRunner());
  final exitCode = await cli.runCommand(arguments);
  exit(exitCode);
}
