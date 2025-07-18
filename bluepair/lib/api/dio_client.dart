import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../storage/storage.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://71e751d224cb.ngrok-free.app', // ✅ Node backend on same PC
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Storage().getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print("🔑 Token used: $token");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            Get.offAllNamed('/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
