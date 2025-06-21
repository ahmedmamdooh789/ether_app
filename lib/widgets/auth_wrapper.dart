import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import 'loading_screen.dart';
import 'error_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  bool? _isAuthenticated;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const LoadingScreen();
    }

    if (_error != null) {
      return ErrorScreen(
        message: 'Error checking authentication status',
        details: _error,
        onRetry: _checkAuthState,
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }

    return _isAuthenticated == true ? const HomeScreen() : const WelcomeScreen();
  }
}
