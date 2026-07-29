import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BdAppsService {
  // Cloud Run Production URL
  static const String _baseUrl = 'https://quiz.solobit.dev';
  late Dio _dio;

  BdAppsService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
  }

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await _dio.post(
        '/send_otp.php',
        data: FormData.fromMap({'user_mobile': mobileNumber}),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String referenceNo, String otp) async {
    try {
      final response = await _dio.post(
        '/verify_otp.php',
        data: FormData.fromMap({'referenceNo': referenceNo, 'Otp': otp}),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<Map<String, dynamic>> checkSubscription(String mobileNumber) async {
    try {
      final response = await _dio.post(
        '/check_subscription.php',
        data: FormData.fromMap({'user_mobile': mobileNumber}),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      throw Exception('Failed to check subscription: $e');
    }
  }

  Future<Map<String, dynamic>> unsubscribe(String mobileNumber) async {
    try {
      final response = await _dio.post(
        '/unsubscribe.php',
        data: FormData.fromMap({'user_mobile': mobileNumber}),
      );
      return response.data;
    } catch (e) {
      debugPrint('Error unsubscribing: $e');
      throw Exception('Failed to unsubscribe: $e');
    }
  }
}
