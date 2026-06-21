import 'dart:io';
import '../models/final_project_blueprint.dart';

class RouterGenerator {
  bool supports(String routing) {
    final normalized = routing.trim().toLowerCase();
    return normalized == 'go router' ||
        normalized == 'navigation 2.0' ||
        normalized == 'auto route' ||
        normalized == 'beamer';
  }

  Future<Map<String, dynamic>> generate(
    String projectPath,
    FinalProjectBlueprint blueprint,
  ) async {
    final routing = blueprint.routing;
    if (!supports(routing)) {
      throw ArgumentError('Unsupported routing option: $routing');
    }

    final normalized = routing.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'routing': routing,
      'generatedDirectories': <String>[],
      'generatedFiles': <String>[],
      'packagesToAdd': <String>[],
    };

    final routerDir = Directory('$projectPath/lib/core/router');

    if (normalized == 'go router') {
      if (!await routerDir.exists()) {
        await routerDir.create(recursive: true);
      }
      final file = File('${routerDir.path}/app_router.dart');
      await file.writeAsString('''
// Router: GoRouter Configuration
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home')),
      ),
    ),
  ],
);
''');
      metadata['generatedDirectories'].add('lib/core/router');
      metadata['generatedFiles'].add('lib/core/router/app_router.dart');
      metadata['packagesToAdd'].add('go_router');
    } else if (normalized == 'navigation 2.0') {
      if (!await routerDir.exists()) {
        await routerDir.create(recursive: true);
      }
      final file = File('${routerDir.path}/router_delegate.dart');
      await file.writeAsString('''
// Router: Navigation 2.0 RouterDelegate
import 'package:flutter/material.dart';

class AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const [
        MaterialPage(
          child: Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
''');
      metadata['generatedDirectories'].add('lib/core/router');
      metadata['generatedFiles'].add('lib/core/router/router_delegate.dart');
    } else if (normalized == 'auto route') {
      if (!await routerDir.exists()) {
        await routerDir.create(recursive: true);
      }
      final file = File('${routerDir.path}/app_router.dart');
      await file.writeAsString('''
// Router: AutoRoute Configuration
import 'package:auto_route/auto_route.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // AutoRoute(page: HomeRoute.page, initial: true),
      ];
}
''');
      metadata['generatedDirectories'].add('lib/core/router');
      metadata['generatedFiles'].add('lib/core/router/app_router.dart');
      metadata['packagesToAdd'].add('auto_route');
    } else if (normalized == 'beamer') {
      if (!await routerDir.exists()) {
        await routerDir.create(recursive: true);
      }
      final file = File('${routerDir.path}/router_location.dart');
      await file.writeAsString('''
// Router: Beamer Router Location
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class HomeLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: Scaffold(body: Center(child: Text('Home'))),
      ),
    ];
  }
}
''');
      metadata['generatedDirectories'].add('lib/core/router');
      metadata['generatedFiles'].add('lib/core/router/router_location.dart');
      metadata['packagesToAdd'].add('beamer');
    }

    return metadata;
  }
}
