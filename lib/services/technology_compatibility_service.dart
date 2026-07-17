import '../models/technology_compatibility.dart';

class TechnologyCompatibilityService {
  bool validate(TechnologyCompatibility compatibility) {
    if (compatibility.stateManagement.trim().isEmpty) return false;
    if (compatibility.routing.trim().isEmpty) return false;
    if (compatibility.sessionStrategy.trim().isEmpty) return false;
    if (compatibility.environmentStrategy.trim().isEmpty) return false;
    return true;
  }

  bool isCompatible(TechnologyCompatibility compatibility) {
    return getConflicts(compatibility).isEmpty;
  }

  List<String> getConflicts(TechnologyCompatibility compatibility) {
    final conflicts = <String>[];

    final state = compatibility.stateManagement.trim();
    final routing = compatibility.routing.trim();
    final session = compatibility.sessionStrategy.trim();
    final env = compatibility.environmentStrategy.trim();
    final scale = compatibility.projectScale.trim();

    final normalizedState = state.toLowerCase();
    final normalizedRouting = routing.toLowerCase();

    // 1. State management / routing compatibility check
    if (normalizedState == 'riverpod') {
      if (normalizedRouting != 'navigation 2.0' &&
          normalizedRouting != 'go router') {
        conflicts.add(
            'Riverpod is only compatible with Navigation 2.0 or Go Router.');
      }
    } else if (normalizedState == 'bloc') {
      if (normalizedRouting != 'navigation 2.0' &&
          normalizedRouting != 'go router') {
        conflicts
            .add('Bloc is only compatible with Navigation 2.0 or Go Router.');
      }
    } else {
      if (normalizedState.isNotEmpty) {
        conflicts.add(
            'Unsupported state management: $state. Only Riverpod and Bloc are supported.');
      }
    }

    // 2. Persistent Session compatibility check
    final normalizedSession = session.toLowerCase();
    if (normalizedSession == 'persistent session' ||
        normalizedSession == 'persistent session architecture') {
      if (normalizedState != 'riverpod' && normalizedState != 'bloc') {
        conflicts.add(
            'Persistent Session is only compatible with Riverpod or Bloc.');
      }
    }

    // 3. Environment Configuration compatibility check
    final normalizedEnv = env.toLowerCase();
    if (normalizedEnv == 'environment configuration' ||
        normalizedEnv == 'environment configuration setup') {
      final normalizedScale = scale.toLowerCase();
      final validScales = [
        'small',
        'medium',
        'enterprise',
        'simple app',
        'medium scale app',
        'enterprise app'
      ];
      if (!validScales.contains(normalizedScale)) {
        conflicts.add(
            'Environment Configuration is only compatible with Small, Medium, or Enterprise scales.');
      }
    }

    return conflicts;
  }
}
