/// Base exception for all app-level errors.
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, {this.cause});

  @override
  String toString() => 'AppException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});

  @override
  String toString() =>
      'DatabaseException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Thrown when input fails validation.
class ValidationException extends AppException {
  /// The field name that failed validation, if applicable.
  final String? field;

  const ValidationException(super.message, {this.field, super.cause});

  @override
  String toString() {
    final fieldPart = field != null ? ' [field: $field]' : '';
    return 'ValidationException$fieldPart: $message';
  }
}

/// Thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});

  @override
  String toString() => 'NotFoundException: $message';
}
