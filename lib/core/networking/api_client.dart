import 'package:dio/dio.dart';

class ApiClient {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) mapper,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    return mapper(response.data);
  }
}
