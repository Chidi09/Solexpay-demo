import 'package:dio/dio.dart';
import 'package:sentry_dio/sentry_dio.dart';
import '../services/token_service.dart';

class ApiClient {
  ApiClient({required TokenService tokenService}) : _tokenService = tokenService {
    _dio = Dio(
      BaseOptions(
        baseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://api.solexpay.com.ng'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

    // Must be the last setup step — wraps the adapter/transformer to add HTTP
    // breadcrumbs and spans (method, URL, status code only — never bodies).
    _dio.addSentry();
  }

  final TokenService _tokenService;
  late final Dio _dio;

  Dio get dio => _dio;
}
