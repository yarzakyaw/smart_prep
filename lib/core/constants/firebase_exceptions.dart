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


/* import 'package:agri_snap/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class FirebaseExceptions implements Exception {
  /// The associated error message.
  final String message;

  /// {@macro log_in_with_email_and_password_failure}
  const FirebaseExceptions(this.message);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory FirebaseExceptions.fromCode(BuildContext context, String code) {
    String translate(String key) => AppLocalizations.of(context).translate(key);

    switch (code) {
      case 'email-already-in-use':
        return FirebaseExceptions(translate('email_in_use'));
      case 'invalid-email':
        return FirebaseExceptions(translate('email_invalid'));
      case 'weak-password':
        return FirebaseExceptions(translate('weak_password'));
      case 'user-disabled':
        return FirebaseExceptions(translate('user_disabled'));
      case 'user-not-found':
        return FirebaseExceptions(translate('user_not_found'));
      case 'wrong-password':
        return FirebaseExceptions(translate('wrong_password'));
      case 'too-many-requests':
        return FirebaseExceptions(translate('too_many_requests'));
      case 'invalid-argument':
        return FirebaseExceptions(translate('invalid_argument'));
      case 'invalid-password':
        return FirebaseExceptions(translate('invalid_password'));
      case 'invalid-phone-number':
        return FirebaseExceptions(translate('invalid_phone'));
      case 'operation-not-allowed':
        return FirebaseExceptions(translate('not_allowed'));
      case 'session-cookie-expired':
        return FirebaseExceptions(translate('session_expired'));
      case 'uid-already-exists':
        return FirebaseExceptions(translate('uid_in_use'));
      default:
        return FirebaseExceptions(translate('app_failure'));
    }
  }
} */



