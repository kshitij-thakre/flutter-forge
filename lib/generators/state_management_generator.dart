import 'dart:io';
import '../models/final_project_blueprint.dart';

class StateManagementGenerator {
  bool supports(String stateManagement) {
    final normalized = stateManagement.trim().toLowerCase();
    return normalized == 'riverpod' ||
        normalized == 'bloc' ||
        normalized == 'provider' ||
        normalized == 'getx';
  }

  Future<Map<String, dynamic>> generate(
    String projectPath,
    FinalProjectBlueprint blueprint,
  ) async {
    final stateManagement = blueprint.stateManagement;
    if (!supports(stateManagement)) {
      throw ArgumentError('Unsupported state management: $stateManagement');
    }

    final normalized = stateManagement.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'stateManagement': stateManagement,
      'generatedDirectories': <String>[],
      'generatedFiles': <String>[],
      'packagesToAdd': <String>[],
    };

    final stateDir = Directory('$projectPath/lib/core/state');

    if (normalized == 'riverpod') {
      if (!await stateDir.exists()) {
        await stateDir.create(recursive: true);
      }
      final file = File('${stateDir.path}/provider_observer.dart');
      await file.writeAsString('''
// State Management: Riverpod Provider Observer
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log state updates here
  }
}
''');
      metadata['generatedDirectories'].add('lib/core/state');
      metadata['generatedFiles'].add('lib/core/state/provider_observer.dart');
      metadata['packagesToAdd'].add('flutter_riverpod');
    } else if (normalized == 'bloc') {
      if (!await stateDir.exists()) {
        await stateDir.create(recursive: true);
      }
      final file = File('${stateDir.path}/bloc_observer.dart');
      await file.writeAsString('''
// State Management: BLoC Observer
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // Log bloc state changes here
  }
}
''');
      metadata['generatedDirectories'].add('lib/core/state');
      metadata['generatedFiles'].add('lib/core/state/bloc_observer.dart');
      metadata['packagesToAdd'].add('flutter_bloc');
    } else if (normalized == 'provider') {
      if (!await stateDir.exists()) {
        await stateDir.create(recursive: true);
      }
      final file = File('${stateDir.path}/base_notifier.dart');
      await file.writeAsString('''
// State Management: Provider Change Notifier
import 'package:flutter/foundation.dart';

abstract class BaseNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
''');
      metadata['generatedDirectories'].add('lib/core/state');
      metadata['generatedFiles'].add('lib/core/state/base_notifier.dart');
      metadata['packagesToAdd'].add('provider');
    } else if (normalized == 'getx') {
      if (!await stateDir.exists()) {
        await stateDir.create(recursive: true);
      }
      final file = File('${stateDir.path}/base_controller.dart');
      await file.writeAsString('''
// State Management: GetX Controller
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
''');
      metadata['generatedDirectories'].add('lib/core/state');
      metadata['generatedFiles'].add('lib/core/state/base_controller.dart');
      metadata['packagesToAdd'].add('get');
    }

    return metadata;
  }
}
