// Production-ready API configuration
// Supports both development and production environments

class ApiConfig {
  // Base URL - change for production
  // For web: use relative paths or your production API domain
  // For mobile: use your production API domain
  static String get baseUrl {
    // In production, this should come from build-time configuration
    // For now, default to localhost for development
    const String envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');
    return envUrl;
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Report endpoints
  static const String submitReport = '/reports/';
  static const String myReports = '/reports/my';
  static const String allReports = '/reports/all';
  static const String modelsInfo = '/reports/models';

  // Analytics
  static const String analytics = '/analytics/';

  // Authority
  static const String resolveIssue = '/authority/resolve';

  // Helper to build full URL
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}