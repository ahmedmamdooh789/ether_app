import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/user.dart';
import '../api/user_service.dart';

@lazySingleton

@injectable
class UserProvider extends ChangeNotifier {
  final UserService _userService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  UserProvider(this._userService);
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load current user
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentUser = await _userService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentUser = await _userService.updateProfile(
        username: username,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<List<User>> searchUsers(String query) async {
    if (_isLoading) return [];
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final results = await _userService.searchUsers(query);
      return results;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
