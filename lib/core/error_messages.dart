import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyError(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is AuthException) {
    final code = (error.code ?? '').toLowerCase();
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'Confirm your email before signing in.';
    }
    if (code == 'user_banned' || message.contains('banned')) {
      return 'This account is deactivated. Contact an admin.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'Network error. Check your connection and try again.';
    }
    // Prefer short Auth message when it is already plain language.
    if (!message.contains('exception') && error.message.length < 120) {
      return error.message;
    }
    return fallback;
  }

  var text = error.toString();
  text = text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  text = text.replaceFirst(RegExp(r'^AuthApiException\([^)]*\)\s*'), '');

  if (text.toLowerCase().contains('invalid login credentials') ||
      text.toLowerCase().contains('invalid_credentials')) {
    return 'Incorrect email or password.';
  }
  if (text.contains('AuthApiException') ||
      text.contains('statusCode') ||
      text.contains('FunctionsHttpException') ||
      text.contains('PostgrestException')) {
    return fallback;
  }

  return text.isEmpty ? fallback : text;
}
