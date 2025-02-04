class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() {
    return 'AppException: $message';
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() {
    return 'AuthException: $message';
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() {
    return 'DatabaseException: $message';
  }
}