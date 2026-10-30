import 'package:flutter/material.dart';

/// Қайталанатын мәтін енгізу өрісі (Figma: Input).
/// obscure = true болса, құпиясөзді көрсету/жасыру белгісі шығады.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscure && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        alignLabelWithHint: widget.maxLines > 1,
        prefixIcon:
            widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Көрсету' : 'Жасыру',
                icon: Icon(_hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
