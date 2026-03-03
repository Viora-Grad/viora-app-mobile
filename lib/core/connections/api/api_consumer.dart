abstract class ApiConsumer {
  Future<dynamic> get(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });
}
