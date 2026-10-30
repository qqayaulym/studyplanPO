import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/database/app_database.dart';
import '../data/auth_service.dart';

/// Login экраны: email мен құпиясөзді тексереді, қате болса түсінікті хабарлама көрсетеді.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _authError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;
    try {
      final ok = await AuthService.instance.login(_email.text, _password.text);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
      } else {
        setState(() => _authError = AppStrings.wrongCredentials);
      }
    } on DbException catch (e) {
      if (mounted) setState(() => _authError = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.event_available, color: cs.onPrimary, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.welcomeBack,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                        fontSize: 16, color: secondaryTextColor(context)),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppStrings.email,
                    controller: _email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: AppStrings.password,
                    controller: _password,
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: Validators.passwordNotEmpty,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ),
                  if (_authError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.error.withAlpha(28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_authError!,
                                style: TextStyle(color: cs.error)),
                          ),
                        ],
                      ),
                    ),
                  AppButton(label: AppStrings.login, onPressed: _submit),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(AppStrings.or,
                            style: TextStyle(color: secondaryTextColor(context))),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: AppStrings.googleLogin,
                    type: AppButtonType.outline,
                    icon: Icons.language,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.googleSoon)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.noAccount,
                          style: TextStyle(color: secondaryTextColor(context))),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.register),
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
