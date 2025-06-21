import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? error;

  ApiResponse({
    this.data,
    this.success = true,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? json)? fromJsonT,
  }) {
    return ApiResponse<T>(
      data: json['data'] != null ? fromJsonT?.call(json['data']) : null,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      error: json['error'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson({
    Object? Function(T? value)? toJsonT,
  }) {
    return {
      'data': data != null ? toJsonT?.call(data) : null,
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'error': error,
    };
  }
}
