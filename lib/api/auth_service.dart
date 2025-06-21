import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user.dart';
import '../utils/api_error_handler.dart';
import '../utils/secure_storage_service.dart';

@injectable
class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthService(this._dio, this._storage);

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      await _storage.saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
      );
      
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<User> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      await _storage.saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
      );
      
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        await _storage.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'] ?? refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      // Call logout API if needed
      await _dio.post('/auth/logout');
    } finally {
      // Always clear tokens
    }
  }
  
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.isLoggedIn();
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/user/profile');
      return User.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? profilePicture,
  }) async {
    try {
      await _dio.put(
        '/user/profile',
        data: {
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
          if (profilePicture != null) 'profile_picture': profilePicture,
        },
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
}
