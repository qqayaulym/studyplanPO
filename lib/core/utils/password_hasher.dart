import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Құпиясөзді ашық түрде сақтамау үшін SHA-256 хэші (email — "тұз" ретінде).
class PasswordHasher {
  PasswordHasher._();

  static String hash(String email, String password) {
    final bytes = utf8.encode('${email.trim().toLowerCase()}:$password');
    return sha256.convert(bytes).toString();
  }
}
