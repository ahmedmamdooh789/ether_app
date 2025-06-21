import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/environment.dart';
import '../utils/token_interceptor.dart';
import '../utils/retry_interceptor.dart';
import '../utils/api_error_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServiceError implements Exception {
  final String message;
  final int? statusCode;
  
  ApiServiceError(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiServiceError: $message';
}

@injectable
class BaseApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  
  BaseApiService(this._storage) {
    _initializeDio();
  }
  
  void _initializeDio() {
    // Create a basic Dio instance without interceptors first
    final dioInstance = Dio(BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Create a new Dio instance for token refresh to avoid circular dependency
    final refreshDio = Dio(BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    // Add interceptors
    dioInstance.interceptors.add(
      TokenInterceptor(
        _storage,
        refreshDio, // Pass the separate Dio instance for refresh
      ),
    );
    
    // Add retry interceptor
    dioInstance.interceptors.add(RetryInterceptor(dio: dioInstance));
    
    _dio = dioInstance;
  }
  
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw ApiServiceError(ApiErrorHandler.handleError(e));
    }
  }
  
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: jsonEncode(data));
      return response.data;
    } catch (e) {
      throw ApiServiceError(ApiErrorHandler.handleError(e));
    }
  }
  
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: jsonEncode(data));
      return response.data;
    } catch (e) {
      throw ApiServiceError(ApiErrorHandler.handleError(e));
    }
  }
  
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } catch (e) {
      throw ApiServiceError(ApiErrorHandler.handleError(e));
    }
  }
}
