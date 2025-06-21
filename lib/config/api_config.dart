class ApiConfig {
  static const String baseUrl = 'https://api.yourapp.com';  // Update with your actual API base URL
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const int timeout = 30000; // 30 seconds
}
