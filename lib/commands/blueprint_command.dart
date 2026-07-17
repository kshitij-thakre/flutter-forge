import 'command.dart';

class BlueprintCommand implements Command {
  @override
  String get name => 'blueprint';

  @override
  String get description => 'Inspect or generate project blueprints.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
