import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          // Render free tier sleeps after idle; cold starts can take 30-60s.
          // A short connectTimeout turns cold starts into connection timeouts.
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    // Add auth interceptor later
  }

  Dio get dio => _dio;
}
