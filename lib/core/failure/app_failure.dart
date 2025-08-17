import 'package:smart_prep/core/constants/text_strings.dart';

class AppFailure {
  final String message;
  AppFailure([this.message = tAppFailureMessage]);

  @override
  String toString() => 'AppFailure(message: $message)';
}
