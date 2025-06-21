import 'package:injectable/injectable.dart';
import '../api/base_api_service.dart';
import '../config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@injectable
class AuthService {
  final BaseApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthService(this._apiService, this._storage);

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final userId = response['user_id'];

      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userIdKey, value: userId.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final response = await _apiService.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
      });

      final token = response['token'];
      final userId = response['user_id'];

      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userIdKey, value: userId.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
}
