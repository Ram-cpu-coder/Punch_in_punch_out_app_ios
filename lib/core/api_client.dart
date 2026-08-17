part of '../main.dart';

class ApiClient {
  ApiClient({required this.token});

  static const requestTimeout = Duration(seconds: 12);

  String token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Uri uri(String path) => Uri.parse('$apiBase$path');

  Future<dynamic> getJson(String path) async {
    return _send(() => http.get(uri(path), headers: headers));
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    return _send(
      () => http.post(uri(path), headers: headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    return _send(
      () => http.put(uri(path), headers: headers, body: jsonEncode(body)),
    );
  }

  Future<void> delete(String path) async {
    await _send(() => http.delete(uri(path), headers: headers));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(requestTimeout);
      return _read(response);
    } on TimeoutException {
      throw ApiError(
          'Connection is slow. Please check internet and try again.');
    } on http.ClientException {
      throw ApiError('Cannot reach the server. Check internet or API status.');
    } on FormatException {
      throw ApiError('Server returned an unexpected response.');
    }
  }

  dynamic _read(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw ApiError(
        body is Map
            ? body['message']?.toString() ?? 'Request failed'
            : 'Request failed',
      );
    }
    return body;
  }
}

class ApiError implements Exception {
  ApiError(this.message);
  final String message;

  @override
  String toString() => message;
}
