import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'token_storage.dart';

class DioClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  DioClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          // Render free tier sleeps after idle; cold starts can take 30-60s.
          // A short connectTimeout turns cold starts into connection timeouts.
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      _AuthInterceptor(_tokenStorage),
    ]);
  }

  TokenStorage get tokenStorage => _tokenStorage;

  Dio get dio => _dio;
}

/// Attaches the ClickShop API JWT (exchanged from a Firebase ID token) to every
/// request so authenticated endpoints (orders, payments, affiliate, profile)
/// receive the `Authorization: Bearer <token>` header.
class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  _AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Skip the token on the token-exchange endpoint itself.
    final path = options.path;
    if (path.endsWith('/auth/firebase')) {
      handler.next(options);
      return;
    }
    final token = _tokenStorage.readSync();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}