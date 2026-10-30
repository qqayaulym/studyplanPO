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

/// Registration экраны: аты, email және құпиясөз (кемінде 8 таңба) валидацияланады.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    try {
      final ok = await AuthService.instance
          .register(_name.text, _email.text, _password.text);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
      } else {
        setState(() => _error = AppStrings.emailExists);
      }
    } on DbException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.back,
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.createAccount,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.registerSubtitle,
                    style: TextStyle(
                        fontSize: 16, color: secondaryTextColor(context)),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppStrings.fullName,
                    controller: _name,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, AppStrings.enterName),
                  ),
                  const SizedBox(height: 12),
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
                    validator: Validators.newPassword,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.shortPassword,
                    style: TextStyle(
                        fontSize: 12, color: secondaryTextColor(context)),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: cs.error)),
                    ),
                  AppButton(label: AppStrings.register, onPressed: _submit),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.haveAccount,
                          style: TextStyle(color: secondaryTextColor(context))),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.login),
                        child: const Text(AppStrings.login),
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
