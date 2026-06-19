/// Responsibility:
/// Handles console logging formatting and messaging outputs (info, warning, error, success).

class Logger {
  // TODO: Add support for terminal colors (ANSI codes) if platform allows.

  void info(String message) {
    // ignore: avoid_print
    print('[INFO] $message');
  }

  void warning(String message) {
    // ignore: avoid_print
    print('[WARNING] $message');
  }

  void error(String message) {
    // ignore: avoid_print
    print('[ERROR] $message');
  }

  void success(String message) {
    // ignore: avoid_print
    print('[SUCCESS] $message');
  }
}
