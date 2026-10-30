import '../constants/app_strings.dart';

/// Форма өрістерін тексеретін функциялар.
class Validators {
  Validators._();

  static final RegExp _emailRegExp =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.enterEmail;
    if (!_emailRegExp.hasMatch(v)) return AppStrings.badEmail;
    return null;
  }

  /// Кіру кезінде тек бос емес екенін тексереміз.
  static String? passwordNotEmpty(String? value) {
    if (value == null || value.isEmpty) return AppStrings.enterPassword;
    return null;
  }

  /// Тіркелу кезінде кемінде 8 таңба талап етіледі.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.enterPassword;
    if (value.length < 8) return AppStrings.shortPassword;
    return null;
  }

  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
