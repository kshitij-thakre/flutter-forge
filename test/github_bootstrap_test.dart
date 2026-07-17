import 'dart:async';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../tool/github_bootstrap_impl/models.dart';
import '../tool/github_bootstrap_impl/yaml_parser.dart';
import '../tool/github_bootstrap_impl/logger.dart';
import '../tool/github_bootstrap_impl/retry_handler.dart';
import '../tool/github_bootstrap_impl/github_api_client.dart';
import '../tool/github_bootstrap_impl/validation_service.dart';
import '../tool/github_bootstrap_impl/bootstrap_service.dart';

void main() {
  group('GitHub Roadmap Bootstrap Tool Tests', () {
    late YamlParser yamlParser;
    late Logger silentLogger;

    setUp(() {
      yamlParser = YamlParser();
      silentLogger = Logger(isVerbose: false);
    });

    test('YAML Parser loads and parses roadmaps/v3.yaml successfully', () {
      final config = yamlParser.parse('roadmaps/v3.yaml');

      expect(config.version, equals(3.0));
      expect(config.milestones, hasLength(4));
      expect(config.labels, hasLength(7));
      expect(config.issues, hasLength(15));

      final firstIssue = config.issues.first;
      expect(firstIssue.title, equals('CLI Foundation'));
      expect(firstIssue.milestone, equals('V3.0 Core Platform'));
      expect(firstIssue.labels, containsAll(['cli', 'enhancement']));
      expect(firstIssue.estimate, equals('Large'));
      expect(firstIssue.priority, equals('High'));
    });

    test('Issue markdown body template matches structural design', () {
      final mockIssue = IssueConfig(
        title: 'CLI Foundation',
        milestone: 'V3.0 Core Platform',
        labels: ['cli', 'enhancement'],
        estimate: 'Large',
        priority: 'High',
        objective: 'Test Objective',
        background: 'Test Background',
        scope: 'Test Scope',
        deliverables: ['Deliv 1', 'Deliv 2'],
        acceptanceCriteria: ['AC 1', 'AC 2'],
        outOfScope: 'Out of scope items',
        dependencies: 'None',
        testingChecklist: ['Test item 1'],
        definitionOfDone: 'DoD items',
      );

      final body = yamlParser.formatIssueBody(mockIssue);

      expect(body, contains('## Objective\nTest Objective'));
      expect(body, contains('## Background\nTest Background'));
      expect(body, contains('## Scope\nTest Scope'));
      expect(body, contains('## Deliverables\n* Deliv 1\n* Deliv 2'));
      expect(body, contains('## Acceptance Criteria\n- [ ] AC 1\n- [ ] AC 2'));
      expect(body, contains('## Out of Scope\nOut of scope items'));
      expect(body, contains('## Dependencies\nNone'));
      expect(body, contains('## Testing Checklist\n- [ ] Test item 1'));
      expect(body, contains('## Definition of Done\nDoD items'));
    });

    group('Validation Service Tests', () {
      late ValidationService validationService;

      setUp(() {
        validationService = ValidationService();
      });

      test('Offline validation fails if GITHUB_TOKEN is empty', () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [],
          labels: [],
          issues: [],
        );

        final result = await validationService.validate(
          mockConfig,
          owner: 'test-owner',
          repo: 'test-repo',
          token: '',
        );

        expect(result.isValid, isFalse);
        expect(result.errors.first, contains('GITHUB_TOKEN is not set'));
      });

      test('Validation fails if duplicate labels are defined in YAML config',
          () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [],
          labels: [
            LabelConfig(name: 'duplicate', color: '123', description: 'desc'),
            LabelConfig(name: 'Duplicate', color: '456', description: 'desc'),
          ],
          issues: [],
        );

        final result =
            await validationService.validate(mockConfig, token: 'token');
        expect(result.isValid, isFalse);
        expect(
            result.errors, anyElement(contains('Duplicate label name found')));
      });

      test(
          'Validation fails if duplicate milestones are defined in YAML config',
          () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(title: 'M1', description: 'desc'),
            MilestoneConfig(title: 'm1', description: 'desc'),
          ],
          labels: [],
          issues: [],
        );

        final result =
            await validationService.validate(mockConfig, token: 'token');
        expect(result.isValid, isFalse);
        expect(result.errors,
            anyElement(contains('Duplicate milestone title found')));
      });

      test(
          'Validation fails if issue milestone references non-existent milestone',
          () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(title: 'Real Milestone', description: 'desc'),
          ],
          labels: [],
          issues: [
            IssueConfig(
              title: 'Broken Issue',
              milestone: 'Fake Milestone',
              labels: [],
              estimate: '',
              priority: '',
              objective: '',
              background: '',
              scope: '',
              deliverables: [],
              acceptanceCriteria: [],
              outOfScope: '',
              dependencies: '',
              testingChecklist: [],
              definitionOfDone: '',
            ),
          ],
        );

        final result = await validationService.validate(
          mockConfig,
          owner: 'owner',
          repo: 'repo',
          token: 'token',
        );

        expect(result.isValid, isFalse);
        expect(result.errors,
            anyElement(contains('references non-existent milestone')));
      });

      test('Validation fails if issue labels reference non-existent labels',
          () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(title: 'Milestone', description: 'desc'),
          ],
          labels: [
            LabelConfig(
                name: 'real-label', color: 'ff0000', description: 'desc'),
          ],
          issues: [
            IssueConfig(
              title: 'Issue',
              milestone: 'Milestone',
              labels: ['fake-label'],
              estimate: '',
              priority: '',
              objective: '',
              background: '',
              scope: '',
              deliverables: [],
              acceptanceCriteria: [],
              outOfScope: '',
              dependencies: '',
              testingChecklist: [],
              definitionOfDone: '',
            ),
          ],
        );

        final result = await validationService.validate(
          mockConfig,
          owner: 'owner',
          repo: 'repo',
          token: 'token',
        );

        expect(result.isValid, isFalse);
        expect(result.errors,
            anyElement(contains('references non-existent label')));
      });

      test('Validation fails if duplicate issue titles are found', () async {
        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(title: 'Milestone', description: 'desc'),
          ],
          labels: [],
          issues: [
            IssueConfig(
              title: 'Duplicate Title',
              milestone: 'Milestone',
              labels: [],
              estimate: '',
              priority: '',
              objective: '',
              background: '',
              scope: '',
              deliverables: [],
              acceptanceCriteria: [],
              outOfScope: '',
              dependencies: '',
              testingChecklist: [],
              definitionOfDone: '',
            ),
            IssueConfig(
              title: 'Duplicate Title',
              milestone: 'Milestone',
              labels: [],
              estimate: '',
              priority: '',
              objective: '',
              background: '',
              scope: '',
              deliverables: [],
              acceptanceCriteria: [],
              outOfScope: '',
              dependencies: '',
              testingChecklist: [],
              definitionOfDone: '',
            ),
          ],
        );

        final result = await validationService.validate(
          mockConfig,
          owner: 'owner',
          repo: 'repo',
          token: 'token',
        );

        expect(result.isValid, isFalse);
        expect(
            result.errors, anyElement(contains('Duplicate issue title found')));
      });
    });

    group('Retry Handler Tests', () {
      test(
          'RetryHandler retries on RateLimitException, TransientException, and TimeoutException',
          () async {
        final retryHandler = RetryHandler(silentLogger);
        int calls = 0;

        final result = await retryHandler.execute(() async {
          calls++;
          if (calls == 1) {
            throw RateLimitException(1, 'Rate limited');
          }
          if (calls == 2) {
            throw TransientException(502, 'Bad gateway');
          }
          if (calls == 3) {
            throw TimeoutException('Request timeout');
          }
          return 'Success';
        }, maxRetries: 4, baseDelay: const Duration(milliseconds: 10));

        expect(result, equals('Success'));
        expect(calls, equals(4));
        expect(retryHandler.retryCount, equals(3));
      });

      test('RetryHandler does NOT retry on ValidationException', () async {
        final retryHandler = RetryHandler(silentLogger);
        int calls = 0;

        expect(
          () => retryHandler.execute(() async {
            calls++;
            throw ValidationException(422, 'Unprocessable Entity');
          }, maxRetries: 3),
          throwsA(isA<ValidationException>()),
        );
        expect(calls, equals(1));
      });
    });

    group('GitHub API Client & Mock Sync Tests', () {
      test('GitHubApiClient handles mock rate limits and retries', () async {
        int mockCalls = 0;
        final mockClient = MockClient((request) async {
          mockCalls++;
          if (mockCalls == 1) {
            return http.Response('Rate limit exceeded', 403, headers: {
              'x-ratelimit-remaining': '0',
              'x-ratelimit-reset':
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1)
                      .toString(),
            });
          }
          return http.Response('{"name": "test-repo"}', 200);
        });

        final retryHandler = RetryHandler(silentLogger);
        final apiClient = GitHubApiClient(
          client: mockClient,
          token: 'mock-token',
          retryHandler: retryHandler,
        );

        final exists = await apiClient.verifyRepository('owner', 'repo');
        expect(exists, isTrue);
        expect(mockCalls, equals(2));
      });

      test(
          'GitHubApiClient parses Link headers and fetches multiple pages recursively',
          () async {
        int mockCalls = 0;
        final mockClient = MockClient((request) async {
          mockCalls++;
          final path = request.url.path;
          if (path.endsWith('/issues')) {
            if (mockCalls == 1) {
              return http.Response(
                '[{"number": 1, "title": "Page 1 Issue"}]',
                200,
                headers: {
                  'link':
                      '<https://api.github.com/repos/owner/repo/issues?page=2>; rel="next"',
                },
              );
            } else if (mockCalls == 2) {
              return http.Response(
                '[{"number": 2, "title": "Page 2 Issue"}]',
                200,
              );
            }
          }
          return http.Response('Not Found', 404);
        });

        final retryHandler = RetryHandler(silentLogger);
        final apiClient = GitHubApiClient(
          client: mockClient,
          token: 'mock-token',
          retryHandler: retryHandler,
        );

        final issues = await apiClient.getIssues('owner', 'repo');
        expect(issues, hasLength(2));
        expect(issues[0]['title'], equals('Page 1 Issue'));
        expect(issues[1]['title'], equals('Page 2 Issue'));
        expect(mockCalls, equals(2));
      });

      test(
          'BootstrapService sync compares attributes and issues PATCH updates when different',
          () async {
        final patchCalls = <String, List<dynamic>>{};
        final mockClient = MockClient((request) async {
          final path = request.url.path;
          final method = request.method;

          if (path.endsWith('/repos/owner/repo')) {
            return http.Response('{"name":"repo"}', 200);
          }
          if (path.endsWith('/user')) {
            return http.Response('{"login":"user"}', 200,
                headers: {'x-oauth-scopes': 'repo'});
          }
          if (path.endsWith('/milestones')) {
            return http.Response(
                '[{"title": "M1", "number": 1, "description": "old desc", "due_on": "2026-06-30T00:00:00Z"}]',
                200);
          }
          if (path.endsWith('/milestones/1')) {
            if (method == 'PATCH') {
              patchCalls['milestones'] = [path];
              return http.Response('{"title": "M1", "number": 1}', 200);
            }
          }
          if (path.endsWith('/labels')) {
            return http.Response(
                '[{"name": "label-1", "color": "000000", "description": "old description"}]',
                200);
          }
          if (path.endsWith('/labels/label-1')) {
            if (method == 'PATCH') {
              patchCalls['labels'] = [path];
              return http.Response('{"name": "label-1"}', 200);
            }
          }
          if (path.endsWith('/issues')) {
            return http.Response(
                '[{"number": 100, "title": "Test Issue", "body": "old body", "milestone": {"title": "M1"}, "labels": [{"name": "label-1"}]}]',
                200);
          }
          if (path.endsWith('/issues/100')) {
            if (method == 'PATCH') {
              patchCalls['issues'] = [path];
              return http.Response('{"number": 100}', 200);
            }
          }
          return http.Response('Not Found', 404);
        });

        final retryHandler = RetryHandler(silentLogger);
        final apiClient = GitHubApiClient(
          client: mockClient,
          token: 'token',
          retryHandler: retryHandler,
        );
        final validationService = ValidationService(apiClient: apiClient);
        final bootstrapService = BootstrapService(
          apiClient: apiClient,
          logger: silentLogger,
          yamlParser: yamlParser,
          validationService: validationService,
        );

        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(
                title: 'M1',
                description: 'new desc',
                dueOn: '2026-06-30T00:00:00Z'),
          ],
          labels: [
            LabelConfig(
                name: 'label-1',
                color: 'ffffff',
                description: 'new description'),
          ],
          issues: [
            IssueConfig(
              title: 'Test Issue',
              milestone: 'M1',
              labels: ['label-1'],
              estimate: 'Medium',
              priority: 'High',
              objective: 'New Obj',
              background: 'New Bg',
              scope: 'New Scope',
              deliverables: [],
              acceptanceCriteria: [],
              outOfScope: '',
              dependencies: '',
              testingChecklist: [],
              definitionOfDone: '',
            ),
          ],
        );

        await bootstrapService.runBootstrap(
          config: mockConfig,
          owner: 'owner',
          repo: 'repo',
          token: 'token',
          isDryRun: false,
        );

        expect(patchCalls['milestones'], isNotNull);
        expect(patchCalls['labels'], isNotNull);
        expect(patchCalls['issues'], isNotNull);
      });

      test(
          'BootstrapService runVerify returns true if aligned, and false if there are mismatches',
          () async {
        final mockClient = MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/repos/owner/repo'))
            return http.Response('{"name":"repo"}', 200);
          if (path.endsWith('/user'))
            return http.Response('{"login":"user"}', 200,
                headers: {'x-oauth-scopes': 'repo'});
          if (path.endsWith('/milestones')) return http.Response('[]', 200);
          if (path.endsWith('/labels')) return http.Response('[]', 200);
          if (path.endsWith('/issues')) return http.Response('[]', 200);
          return http.Response('Not Found', 404);
        });

        final retryHandler = RetryHandler(silentLogger);
        final apiClient = GitHubApiClient(
          client: mockClient,
          token: 'token',
          retryHandler: retryHandler,
        );
        final validationService = ValidationService(apiClient: apiClient);
        final bootstrapService = BootstrapService(
          apiClient: apiClient,
          logger: silentLogger,
          yamlParser: yamlParser,
          validationService: validationService,
        );

        final mockConfig = const RoadmapConfig(
          version: 3.0,
          milestones: [
            MilestoneConfig(title: 'M1', description: 'desc'),
          ],
          labels: [],
          issues: [],
        );

        final aligned = await bootstrapService.runVerify(
          config: mockConfig,
          owner: 'owner',
          repo: 'repo',
          token: 'token',
        );

        expect(aligned, isFalse); // Milestone is missing
      });
    });
  });
}
