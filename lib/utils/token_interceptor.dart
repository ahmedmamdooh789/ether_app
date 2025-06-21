import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions request, ErrorInterceptorHandler handler})> _requestsQueue = [];
  
  TokenInterceptor(this._storage, @factoryParam this._dio);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for refresh token endpoint
    if (options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    
    // Check if the error is due to an expired token
    if (response?.statusCode == 401 && 
        !err.requestOptions.path.contains('/auth/refresh')) {
      
      // If we're already refreshing, add the request to the queue
      if (_isRefreshing) {
        return _addToQueue(err.requestOptions, handler);
      }
      
      _isRefreshing = true;
      
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        
        if (refreshToken == null) {
          // No refresh token available, clear all tokens and reject all requests
          await _storage.deleteAll();
          _rejectAllRequests('No refresh token available');
          return handler.next(err);
        }
        
        // Try to refresh the token
        final tokenResponse = await _refreshToken(refreshToken);
        
        if (tokenResponse != null) {
          // Save new tokens
          await _storage.write(key: 'access_token', value: tokenResponse['access_token']);
          if (tokenResponse['refresh_token'] != null) {
            await _storage.write(key: 'refresh_token', value: tokenResponse['refresh_token']);
          }
          
          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${tokenResponse['access_token']}';
          
          // Retry all queued requests
          await _retryAllRequests();
          
          // Retry the original request
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } else {
          // Refresh failed, clear tokens and reject all requests
          await _storage.deleteAll();
          _rejectAllRequests('Failed to refresh token');
          return handler.next(err);
        }
      } catch (e) {
        // Refresh failed, clear tokens and reject all requests
        await _storage.deleteAll();
        _rejectAllRequests('Token refresh failed: $e');
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }
    
    return handler.next(err);
  }
  
  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  void _addToQueue(RequestOptions request, ErrorInterceptorHandler handler) {
    _requestsQueue.add((request: request, handler: handler));
  }
  
  Future<void> _retryAllRequests() async {
    final accessToken = await _storage.read(key: 'access_token');
    
    for (final entry in _requestsQueue) {
      try {
        entry.request.headers['Authorization'] = 'Bearer $accessToken';
        final response = await _dio.fetch(entry.request);
        entry.handler.resolve(response);
      } catch (e) {
        entry.handler.next(DioException(
          requestOptions: entry.request,
          error: e,
        ));
      }
    }
    
    _requestsQueue.clear();
  }
  
  void _rejectAllRequests(String message) {
    for (final entry in _requestsQueue) {
      entry.handler.next(DioException(
        requestOptions: entry.request,
        error: message,
      ));
    }
    _requestsQueue.clear();
  }
}
