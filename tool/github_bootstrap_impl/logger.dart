import 'dart:io';

class Logger {
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';
  static const String _bold = '\x1B[1m';
  static const String _reset = '\x1B[0m';

  final bool isVerbose;

  Logger({this.isVerbose = true});

  void success(String message) {
    _print('$_green✓ $message$_reset');
  }

  void info(String message) {
    if (isVerbose) {
      _print('$_cyanℹ $message$_reset');
    }
  }

  void warning(String message) {
    _print('$_yellow⚠ WARNING: $message$_reset');
  }

  void error(String message) {
    _print('$_red✗ ERROR: $message$_reset');
  }

  void bold(String message) {
    _print('$_bold$message$_reset');
  }

  void printSummary({
    required int milestonesCreated,
    required int milestonesUpdated,
    required int labelsCreated,
    required int labelsUpdated,
    required int issuesCreated,
    required int warningsCount,
    required int errorsCount,
    required Duration duration,
    bool isDryRun = false,
  }) {
    print('\n==================================================');
    bold(isDryRun
        ? '          Dry Run Validation Summary'
        : '          Execution Summary');
    print('==================================================');
    print(
        'Milestones Synced (Created/Updated):  $milestonesCreated / $milestonesUpdated');
    print(
        'Labels Synced (Created/Updated):      $labelsCreated / $labelsUpdated');
    print('Issues Synced (Created):              $issuesCreated');
    print('Warnings:                             $warningsCount');
    print('Errors:                               $errorsCount');
    print(
        'Execution Time:                       ${duration.inMilliseconds} ms');
    print('==================================================\n');
  }

  void _print(String formattedMessage) {
    stdout.writeln(formattedMessage);
  }
}
