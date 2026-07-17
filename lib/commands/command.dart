abstract class Command {
  String get name;
  String get description;
  Future<int> execute(List<String> args);
}
