import 'package:flutter/material.dart';
import 'package:morphixapp/core/utils/colors.dart';

class NeonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const NeonTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.softBlue),
        prefixIcon: Icon(icon, color: AppColors.textGray),
        // Focused border inherits the neon teal color from theme.dart
      ),
    );
  }
}