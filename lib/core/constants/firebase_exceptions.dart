import 'package:smart_prep/core/constants/text_strings.dart';

class FirebaseExceptions implements Exception {
  /// The associated error message.
  final String message;

  /// {@macro log_in_with_email_and_password_failure}
  const FirebaseExceptions([this.message = tAppFailureMessage]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory FirebaseExceptions.fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const FirebaseExceptions(tEmailInUse);
      case 'invalid-email':
        return const FirebaseExceptions(tInValid);
      case 'weak-password':
        return const FirebaseExceptions(tWeakPassword);
      case 'user-disabled':
        return const FirebaseExceptions(tUserDisabled);
      case 'user-not-found':
        return const FirebaseExceptions(tUserNotFound);
      case 'wrong-password':
        return const FirebaseExceptions(tWrongPassword);
      case 'too-many-requests':
        return const FirebaseExceptions(tManyRequests);
      case 'invalid-argument':
        return const FirebaseExceptions(tInvalidArgument);
      case 'invalid-password':
        return const FirebaseExceptions(tInvalidPassword);
      case 'invalid-phone-number':
        return const FirebaseExceptions(tInvalidPhone);
      case 'operation-not-allowed':
        return const FirebaseExceptions(tNotAllowed);
      case 'session-cookie-expired':
        return const FirebaseExceptions(tSessionExpired);
      case 'uid-already-exists':
        return const FirebaseExceptions(tUidInUse);
      default:
        return const FirebaseExceptions();
    }
  }
}
