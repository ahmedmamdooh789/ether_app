import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user.dart';
import '../utils/api_error_handler.dart';

@injectable
class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<User> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _dio.post('/users/$userId/follow');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/users/$userId/follow');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<User> updateProfile({
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/me',
        data: {
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        },
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<User>> searchUsers(String query, {int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/users/search',
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<User>> getFollowers(String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$userId/followers',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<User>> getFollowing(String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$userId/following',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<bool> checkFollowStatus(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/follow-status');
      return response.data['following'];
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
}
