class AppConstants {
  static const String appName = 'LiveStream Platform';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.livestream-platform.com/v1';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Roles
  static const String roleUser = 'user';
  static const String roleHost = 'host';
  static const String roleAgent = 'agent';
  static const String roleAgency = 'agency';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';
  
  // Default values
  static const String defaultCountryCode = 'IN';
  static const String defaultLanguage = 'en';
}
