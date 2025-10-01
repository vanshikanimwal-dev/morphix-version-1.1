import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/main.dart'; // Import to access authNotifierProvider
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/neon_textfield.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // FIX 1: Use the correct provider (authNotifierProvider) and access its notifier
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      // FIX 2: Call the signUp method with the positional arguments (email, password).
      // The simulated AuthNotifier does not use displayName.
      await authNotifier.signUp(
        emailController.text.trim(),
        passwordController.text,
      );

      // Success: Router's redirect handles navigation to /dashboard

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: ${e.toString().split(']').last.trim()}')),
      );
    } finally {
      // Only set loading to false if the sign-up attempt failed (i.e., if no redirection is imminent)
      if (ref.read(authStateProvider).hasError) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Morphix Account',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.neonTeal, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              NeonTextField(
                controller: displayNameController,
                labelText: 'Display Name (Optional)',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              NeonTextField(
                controller: emailController,
                labelText: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              NeonTextField(
                controller: passwordController,
                labelText: 'Password (min 6 chars)',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                  : NeonButton(
                text: 'Create Account',
                onPressed: _handleSignUp,
                neonColor: AppColors.electricPurple,
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(color: AppColors.textGray)),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Log In', style: TextStyle(color: AppColors.softBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}