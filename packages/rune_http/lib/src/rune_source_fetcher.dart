import 'package:http/http.dart' as http;

/// Raised by a [RuneSourceFetcher] when the origin is unreachable
/// or returns a non-2xx response.
class RuneSourceFetchException implements Exception {
  /// Wraps a failure fetching [url]. [statusCode] is the HTTP
  /// response code when the server answered, `null` when the
  /// transport itself threw (DNS, timeout, TLS). [cause] is the
  /// underlying exception if any.
  const RuneSourceFetchException(
    this.url,
    this.message, {
    this.statusCode,
    this.cause,
  });

  /// The URL that failed.
  final String url;

  /// Short human-readable message.
  final String message;

  /// HTTP status code, when the server responded at all.
  final int? statusCode;

  /// Wrapped exception from the underlying HTTP client, when
  /// applicable.
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' [status $statusCode]';
    return 'RuneSourceFetchException$status: $message (url: $url)';
  }
}

/// Pluggable fetcher contract. The bundled [HttpRuneSourceFetcher]
/// uses `package:http`; tests can substitute a fake implementation.
///
/// The single-method shape is intentional: the interface exists so
/// the production [HttpRuneSourceFetcher] and test fakes can live
/// behind one type at a `RuneHttpView` boundary.
// ignore: one_member_abstracts
abstract interface class RuneSourceFetcher {
  /// Fetches the source at [url] and returns the response body as
  /// a String. Throws [RuneSourceFetchException] on transport or
  /// protocol failures.
  Future<String> fetch(String url);
}

/// Default HTTP-based implementation of [RuneSourceFetcher].
///
/// Wraps `package:http`'s `get`, treats 2xx as success, and maps
/// every other outcome to [RuneSourceFetchException] with the
/// offending URL and status code attached.
final class HttpRuneSourceFetcher implements RuneSourceFetcher {
  /// Creates a fetcher. [client] defaults to `http.Client()`. Pass
  /// a shared client in production to reuse connections; pass a
  /// `http.MockClient` in tests to script responses.
  HttpRuneSourceFetcher({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> fetch(String url) async {
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(url));
    } on Object catch (e) {
      throw RuneSourceFetchException(
        url,
        'Transport error: $e',
        cause: e,
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }
    throw RuneSourceFetchException(
      url,
      'Non-2xx response.',
      statusCode: response.statusCode,
    );
  }
}
