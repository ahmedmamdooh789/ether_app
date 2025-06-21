import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../providers/providers.dart';

/// A utility class to access providers throughout the app
class ProviderUtils {
  /// Get the AuthProvider instance
  static AuthProvider get authProvider => GetIt.instance<AuthProvider>();
  
  /// Get the UserProvider instance
  static UserProvider get userProvider => GetIt.instance<UserProvider>();
  
  /// Get the PostProvider instance
  static PostProvider get postProvider => GetIt.instance<PostProvider>();
  
  /// Get the StoryProvider instance
  static StoryProvider get storyProvider => GetIt.instance<StoryProvider>();
  
  /// Initialize all providers with their required dependencies
  static Future<void> initializeProviders() async {
    // Initialize any providers that need async initialization
    await GetIt.instance.allReady();
  }
}
