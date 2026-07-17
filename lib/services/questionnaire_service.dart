import 'dart:io';
import '../models/project_requirements.dart';

abstract class Question {
  final String text;
  final String key;

  Question({required this.text, required this.key});

  dynamic ask();
}

class ChoiceQuestion extends Question {
  final List<String> choices;

  ChoiceQuestion({
    required super.text,
    required super.key,
    required this.choices,
  });

  @override
  dynamic ask() {
    while (true) {
      print('\n$text');
      for (var i = 0; i < choices.length; i++) {
        print('  [${i + 1}] ${choices[i]}');
      }
      stdout.write('Select option (1-${choices.length}): ');
      final input = stdin.readLineSync()?.trim();

      if (input == null || input.isEmpty) {
        print('Input cannot be empty. Please try again.');
        continue;
      }

      final index = int.tryParse(input);
      if (index == null || index < 1 || index > choices.length) {
        print(
            'Invalid option. Please enter a number between 1 and ${choices.length}.');
        continue;
      }

      return choices[index - 1];
    }
  }
}

class YesNoQuestion extends Question {
  YesNoQuestion({
    required super.text,
    required super.key,
  });

  @override
  dynamic ask() {
    while (true) {
      print('\n$text');
      print('  [1] Yes');
      print('  [2] No');
      stdout.write('Select option (1-2) or enter (y/n): ');
      final input = stdin.readLineSync()?.trim().toLowerCase();

      if (input == null || input.isEmpty) {
        print('Input cannot be empty. Please try again.');
        continue;
      }

      if (input == '1' || input == 'y' || input == 'yes') {
        return true;
      }
      if (input == '2' || input == 'n' || input == 'no') {
        return false;
      }

      print('Invalid input. Please enter 1, 2, y, or n.');
    }
  }
}

class QuestionnaireService {
  final List<Question> _questions = [
    ChoiceQuestion(
      text: 'Which state management would you like to use?',
      key: 'stateManagement',
      choices: ['Riverpod', 'Bloc', 'Provider', 'Recommend for me'],
    ),
    ChoiceQuestion(
      text: 'Which routing solution would you like to use?',
      key: 'routing',
      choices: [
        'Navigation 2.0',
        'Go Router',
        'Auto Route',
        'Recommend for me'
      ],
    ),
    ChoiceQuestion(
      text: 'What type of application are you building?',
      key: 'projectScale',
      choices: ['Simple App', 'Medium Scale App', 'Enterprise App'],
    ),
    ChoiceQuestion(
      text: 'Approximately how many screens will your application have?',
      key: 'screenCount',
      choices: ['1-10', '10-30', '30-100', '100+'],
    ),
    YesNoQuestion(
      text: 'Will authentication be required?',
      key: 'authenticationRequired',
    ),
    YesNoQuestion(
      text: 'Will session persistence be required?',
      key: 'sessionRequired',
    ),
    ChoiceQuestion(
      text: 'Which environments do you need?',
      key: 'environmentSetup',
      choices: ['Dev only', 'Dev + Stage', 'Dev + Stage + Production'],
    ),
  ];

  Future<ProjectRequirements> run() async {
    final answers = <String, dynamic>{};

    print('\n==================================================');
    print('          Ironship Project Discovery Engine');
    print('==================================================');

    for (final question in _questions) {
      answers[question.key] = question.ask();
    }

    return ProjectRequirements(
      stateManagement: answers['stateManagement'] as String,
      routing: answers['routing'] as String,
      projectScale: answers['projectScale'] as String,
      screenCount: answers['screenCount'] as String,
      authenticationRequired: answers['authenticationRequired'] as bool,
      sessionRequired: answers['sessionRequired'] as bool,
      environmentSetup: answers['environmentSetup'] as String,
    );
  }
}
