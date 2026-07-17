import 'dart:async';
import 'dart:io';
import 'logger.dart';
import 'github_api_client.dart';

class RateLimitException implements Exception {
  final int retryAfterSeconds;
  final String message;

  RateLimitException(this.retryAfterSeconds, this.message);

  @override
  String toString() =>
      'RateLimitException: $message (Retry after $retryAfterSeconds seconds)';
}

class TransientException implements Exception {
  final int statusCode;
  final String message;

  TransientException(this.statusCode, this.message);

  @override
  String toString() => 'TransientException: Status $statusCode - $message';
}

class RetryHandler {
  final Logger logger;
  int retryCount = 0;

  RetryHandler(this.logger);

  Future<T> execute<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration baseDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        return await action();
      } catch (e) {
        if (e is ValidationException) {
          logger.error('Fatal client validation error: $e. Aborting retries.');
          rethrow;
        }

        if (attempts >= maxRetries) {
          logger.error(
              'Max retry attempts ($maxRetries) reached. Failing with: $e');
          rethrow;
        }

        retryCount++;
        int delaySeconds = 0;
        if (e is RateLimitException) {
          delaySeconds = e.retryAfterSeconds;
          logger.warning(
              'Rate limit hit. Retrying in $delaySeconds seconds... (Attempt $attempts/$maxRetries)');
        } else if (e is TransientException) {
          delaySeconds = baseDelay.inSeconds * attempts;
          logger.warning(
              'Transient error (${e.statusCode}) encountered. Retrying in $delaySeconds seconds... (Attempt $attempts/$maxRetries)');
        } else if (e is TimeoutException) {
          delaySeconds = baseDelay.inSeconds * attempts;
          logger.warning(
              'Request timed out. Retrying in $delaySeconds seconds... (Attempt $attempts/$maxRetries)');
        } else if (e is SocketException || e is HttpException) {
          delaySeconds = baseDelay.inSeconds * attempts;
          logger.warning(
              'Network connection error: $e. Retrying in $delaySeconds seconds... (Attempt $attempts/$maxRetries)');
        } else {
          logger
              .error('Unexpected exception encountered: $e. Aborting retries.');
          rethrow;
        }

        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
  }
}
