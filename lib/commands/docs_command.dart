import 'command.dart';

class DocsCommand implements Command {
  @override
  String get name => 'docs';

  @override
  String get description => 'Generate documentation for the codebase.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
