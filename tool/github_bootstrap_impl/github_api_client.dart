import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'retry_handler.dart';

class ValidationException implements Exception {
  final int statusCode;
  final String message;

  ValidationException(this.statusCode, this.message);

  @override
  String toString() => 'ValidationException (Status $statusCode): $message';
}

class GitHubApiClient {
  final http.Client client;
  final String token;
  final RetryHandler retryHandler;
  final Duration timeout;

  GitHubApiClient({
    required this.client,
    required this.token,
    required this.retryHandler,
    this.timeout = const Duration(seconds: 10),
  });

  Map<String, String> get _headers => {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Ironship-Roadmap-Bootstrap',
        'Content-Type': 'application/json',
      };

  Future<void> _checkResponse(http.Response response) async {
    final status = response.statusCode;
    if (status == 403 || status == 429) {
      final delay = _getRateLimitDelay(response.headers);
      throw RateLimitException(delay, 'GitHub API Rate Limit Exceeded or Access Forbidden.');
    }
    if (status == 400 || status == 401 || status == 422) {
      throw ValidationException(status, 'GitHub Validation/Client Error: ${response.body}');
    }
    if (status >= 500) {
      throw TransientException(status, 'GitHub Server Error: ${response.body}');
    }
    if (status >= 400) {
      throw HttpException('GitHub API Error (Status $status): ${response.body}');
    }
  }

  int _getRateLimitDelay(Map<String, String> headers) {
    final retryAfter = headers['retry-after'];
    if (retryAfter != null) {
      return int.tryParse(retryAfter) ?? 60;
    }
    final reset = headers['x-ratelimit-reset'];
    if (reset != null) {
      final resetTime = int.tryParse(reset);
      if (resetTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final diff = resetTime - now;
        return diff > 0 ? diff : 1;
      }
    }
    return 60;
  }

  String? _getNextPageUrl(String? linkHeader) {
    if (linkHeader == null || linkHeader.isEmpty) return null;
    final parts = linkHeader.split(',');
    for (final part in parts) {
      final subparts = part.split(';');
      if (subparts.length < 2) continue;
      final urlPart = subparts[0].trim();
      final relPart = subparts[1].trim();
      if (relPart.contains('rel="next"')) {
        if (urlPart.startsWith('<') && urlPart.endsWith('>')) {
          return urlPart.substring(1, urlPart.length - 1);
        }
        return urlPart;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchPagedList(String initialUrl) async {
    final results = <Map<String, dynamic>>[];
    String? nextUrl = initialUrl;
    while (nextUrl != null) {
      final response = await client
          .get(Uri.parse(nextUrl), headers: _headers)
          .timeout(timeout);
      await _checkResponse(response);
      final list = jsonDecode(response.body) as List<dynamic>;
      results.addAll(list.cast<Map<String, dynamic>>());
      nextUrl = _getNextPageUrl(response.headers['link']);
    }
    return results;
  }

  Future<bool> verifyRepository(String owner, String repo) async {
    return retryHandler.execute(() async {
      final response = await client
          .get(
            Uri.parse('https://api.github.com/repos/$owner/$repo'),
            headers: _headers,
          )
          .timeout(timeout);
      if (response.statusCode == 200) return true;
      if (response.statusCode == 404) return false;
      await _checkResponse(response);
      return false;
    });
  }

  Future<Map<String, dynamic>> verifyTokenPermissions() async {
    return retryHandler.execute(() async {
      final response = await client
          .get(
            Uri.parse('https://api.github.com/user'),
            headers: _headers,
          )
          .timeout(timeout);
      await _checkResponse(response);
      return {
        'scopes': response.headers['x-oauth-scopes'] ?? '',
        'body': jsonDecode(response.body),
      };
    });
  }

  Future<List<Map<String, dynamic>>> getMilestones(String owner, String repo) async {
    return retryHandler.execute(() async {
      final initialUrl = 'https://api.github.com/repos/$owner/$repo/milestones?state=all&per_page=100';
      return await _fetchPagedList(initialUrl);
    });
  }

  Future<Map<String, dynamic>> createMilestone(
      String owner, String repo, String title, String description, {String? dueOn}) async {
    return retryHandler.execute(() async {
      final response = await client.post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/milestones'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          if (dueOn != null && dueOn.isNotEmpty) 'due_on': dueOn,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateMilestone(
      String owner, String repo, int number, String title, String description, {String? dueOn}) async {
    return retryHandler.execute(() async {
      final response = await client.patch(
        Uri.parse('https://api.github.com/repos/$owner/$repo/milestones/$number'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'due_on': (dueOn != null && dueOn.isNotEmpty) ? dueOn : null,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> getLabels(String owner, String repo) async {
    return retryHandler.execute(() async {
      final initialUrl = 'https://api.github.com/repos/$owner/$repo/labels?per_page=100';
      return await _fetchPagedList(initialUrl);
    });
  }

  Future<Map<String, dynamic>> createLabel(
      String owner, String repo, String name, String color, String description) async {
    return retryHandler.execute(() async {
      final response = await client.post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/labels'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'color': color.replaceAll('#', ''),
          'description': description,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateLabel(
      String owner, String repo, String name, String color, String description) async {
    return retryHandler.execute(() async {
      final response = await client.patch(
        Uri.parse('https://api.github.com/repos/$owner/$repo/labels/$name'),
        headers: _headers,
        body: jsonEncode({
          'color': color.replaceAll('#', ''),
          'description': description,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> getIssues(String owner, String repo) async {
    return retryHandler.execute(() async {
      final initialUrl = 'https://api.github.com/repos/$owner/$repo/issues?state=all&per_page=100';
      return await _fetchPagedList(initialUrl);
    });
  }

  Future<Map<String, dynamic>> createIssue(
    String owner,
    String repo,
    String title,
    String body,
    int? milestoneNumber,
    List<String> labels,
  ) async {
    return retryHandler.execute(() async {
      final response = await client.post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/issues'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'body': body,
          'milestone': milestoneNumber,
          'labels': labels,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateIssue(
    String owner,
    String repo,
    int issueNumber,
    String title,
    String body,
    int? milestoneNumber,
    List<String> labels,
  ) async {
    return retryHandler.execute(() async {
      final response = await client.patch(
        Uri.parse('https://api.github.com/repos/$owner/$repo/issues/$issueNumber'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'body': body,
          'milestone': milestoneNumber,
          'labels': labels,
        }),
      ).timeout(timeout);
      await _checkResponse(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<void> deleteMilestone(String owner, String repo, int number) async {
    await retryHandler.execute(() async {
      final response = await client.delete(
        Uri.parse('https://api.github.com/repos/$owner/$repo/milestones/$number'),
        headers: _headers,
      );
      await _checkResponse(response);
    });
  }

  Future<void> closeIssue(String owner, String repo, int issueNumber) async {
    await retryHandler.execute(() async {
      final response = await client.patch(
        Uri.parse('https://api.github.com/repos/$owner/$repo/issues/$issueNumber'),
        headers: _headers,
        body: jsonEncode({'state': 'closed'}),
      ).timeout(timeout);
      await _checkResponse(response);
    });
  }

  Future<void> deleteLabel(String owner, String repo, String name) async {
    await retryHandler.execute(() async {
      final response = await client.delete(
        Uri.parse('https://api.github.com/repos/$owner/$repo/labels/$name'),
        headers: _headers,
      );
      await _checkResponse(response);
    });
  }
}
