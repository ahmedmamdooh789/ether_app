import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment current = Environment.development;
  
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'https://api-dev.yourapp.com';
      case Environment.staging:
        return 'https://api-staging.yourapp.com';
      case Environment.production:
        return 'https://api.yourapp.com';
    }
  }
  
  static bool get isProduction => current == Environment.production;
  
  static Future<void> init() async {
    // Initialize environment settings
    // For now, we're using development environment by default
    setEnvironment(Environment.development);
    
    // Add any other initialization logic here
  }
  
  static void setEnvironment(Environment env) {
    current = env;
    // Update any other environment-specific configurations here
  }
}
