import 'command.dart';
import 'command_registry.dart';

class HelpCommand implements Command {
  final CommandRegistry registry;

  HelpCommand(this.registry);

  @override
  String get name => 'help';

  @override
  String get description => 'Show help information.';

  @override
  Future<int> execute(List<String> args) async {
    registry.printHelp();
    return 0;
  }
}
