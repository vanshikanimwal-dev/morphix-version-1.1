import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
// Assuming main.dart exposes authNotifierProvider
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/neon_textfield.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // FIX: Use the correct provider (authNotifierProvider) and access its notifier
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      // FIX: Call the correct method from AuthNotifier
      await authNotifier.forgotPassword(emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email.')),
      );
      context.go(AppRoutes.login);

    } catch (e) {
      // Note: The AuthNotifier is simulated and doesn't actually throw specific errors,
      // but we keep the structure for a real Firebase implementation.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset link: ${e.toString().split(']').last.trim()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.softBlue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              NeonTextField(
                controller: emailController,
                labelText: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.softBlue))
                  : NeonButton(
                text: 'Send Reset Link',
                onPressed: _handleResetPassword,
                neonColor: AppColors.softBlue,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Back to Login', style: TextStyle(color: AppColors.textGray)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}