import 'command.dart';

class CommandRegistry {
  final Map<String, Command> _commands = {};

  void register(Command command) {
    _commands[command.name] = command;
  }

  Command? getCommand(String name) {
    return _commands[name];
  }

  List<Command> get allCommands => _commands.values.toList();

  bool hasCommand(String name) {
    return _commands.containsKey(name);
  }

  bool validateCommand(String name) {
    return hasCommand(name);
  }

  void printHelp() {
    print('Ironship\n');
    print('Flutter Architecture Assistant\n');
    print('Usage\n');
    print('  forge <command>\n');
    print('Commands\n');
    for (final cmd in allCommands) {
      print('  ${cmd.name}');
    }
    print('\nOptions\n');
    print('  --help');
    print('  --version');
  }
}
