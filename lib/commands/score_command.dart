import 'command.dart';

class ScoreCommand implements Command {
  @override
  String get name => 'score';

  @override
  String get description => 'Evaluate code quality and architecture score.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
