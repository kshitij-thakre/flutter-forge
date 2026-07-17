import 'command.dart';

class ModuleCommand implements Command {
  @override
  String get name => 'module';

  @override
  String get description => 'Manage package modules.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
