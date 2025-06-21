import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handleError(dynamic error) {
    String errorDescription = "";
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorDescription = "Connection timeout";
          break;
        case DioExceptionType.sendTimeout:
          errorDescription = "Send timeout";
          break;
        case DioExceptionType.receiveTimeout:
          errorDescription = "Receive timeout";
          break;
        case DioExceptionType.badResponse:
          errorDescription = _handleErrorFromResponse(error.response!);
          break;
        case DioExceptionType.cancel:
          errorDescription = "Request cancelled";
          break;
        case DioExceptionType.unknown:
          errorDescription = "Unexpected error occurred";
          break;
        default:
          errorDescription = "Something went wrong";
      }
    } else {
      errorDescription = "Unexpected error occurred";
    }
    
    return errorDescription;
  }
  
  static String _handleErrorFromResponse(Response response) {
    switch (response.statusCode) {
      case 400:
        return "Bad request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not found";
      case 500:
        return "Internal server error";
      default:
        return "Something went wrong";
    }
  }
}
