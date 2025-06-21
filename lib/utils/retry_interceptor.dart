import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final List<int> retryStatusCodes;
  final Dio _dio;
  
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.retryStatusCodes = const [500, 502, 503, 504],
  }) : _dio = dio;
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Store the Dio instance in the request options
    options.extra['dio'] = _dio;
    handler.next(options);
  }
  
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null && 
        retryStatusCodes.contains(err.response!.statusCode)) {
      
      // Get or initialize retry count
      int retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        
        // Create a new request with updated options
        final newOptions = err.requestOptions.copyWith();
        newOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await err.requestOptions.extra['dio']!.fetch(newOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return handler.next(e);
          } else {
            return handler.next(DioException(
              error: e,
              requestOptions: newOptions,
              type: DioExceptionType.unknown,
            ));
          }
        }
      }
    }
    
    return handler.next(err);
  }
}
