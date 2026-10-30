import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/content_width.dart';

/// Құпиясөзді қалпына келтіру: email тексеріліп, сілтеме жіберілді деген хабарлама көрсетіледі.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(AppStrings.linkSent)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.resetTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.resetText,
                    style: TextStyle(
                        fontSize: 16, color: secondaryTextColor(context)),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppStrings.email,
                    controller: _email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    onSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: 24),
                  AppButton(label: AppStrings.sendLink, onPressed: _send),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
