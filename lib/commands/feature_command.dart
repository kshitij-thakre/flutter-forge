import 'command.dart';

class FeatureCommand implements Command {
  @override
  String get name => 'feature';

  @override
  String get description => 'Scaffold feature modules.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
