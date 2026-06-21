import 'dart:convert';
import 'package:ironship/services/questionnaire_service.dart';

void main() async {
  final service = QuestionnaireService();
  final requirements = await service.run();
  
  print('\nVerification Output (JSON):');
  print(jsonEncode(requirements.toJson()));
}
