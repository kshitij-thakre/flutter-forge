import 'dart:convert';
import 'package:ironship/services/discovery_pipeline_service.dart';

void main() async {
  print('Starting Discovery Pipeline Verification Test...\n');

  final pipeline = DiscoveryPipelineService();
  final config = await pipeline.execute('pipeline_test_app');

  print('\nVerification Output (JSON):');
  print(jsonEncode(config.toJson()));
}
