import 'command.dart';

class DoctorCommand implements Command {
  @override
  String get name => 'doctor';

  @override
  String get description => 'Validate project health and environment setup.';

  @override
  Future<int> execute(List<String> args) async {
    print('Not Implemented Yet');
    return 0;
  }
}
