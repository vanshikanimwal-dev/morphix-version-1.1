import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/main.dart'; // Import to access authNotifierProvider
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/neon_textfield.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);

    // FIX 1: Use the correct provider (authNotifierProvider) and access its notifier
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      // FIX 2: Call the signIn method with positional arguments (email, password)
      await authNotifier.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      // Success: Router's redirect handles navigation to /dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed. Please check credentials: ${e.toString().split(']').last.trim()}')),
      );
    } finally {
      // Crucially, don't stop loading if the router is about to redirect.
      // But we must stop loading if the signIn attempt failed.
      if (ref.read(authStateProvider).hasError) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    // FIX 3: Since AuthNotifier is simulated, we'll just sign in a regular user
    // and show a message indicating Google Sign-in is a premium feature.
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      // Simulate that Google Sign-in requires an extra step or is premium-gated
      await authNotifier.signIn("premium@morphix.pro", "password"); // Sign in as premium mock

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In uses premium access for advanced features.')),
      );
      // Success: Router's redirect handles navigation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Failed: ${e.toString()}')),
      );
    } finally {
      if (ref.read(authStateProvider).hasError) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Access the Grid',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.electricPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              NeonTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              NeonTextField(
                controller: passwordController,
                labelText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?', style: TextStyle(color: AppColors.textGray)),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                  : NeonButton(
                text: 'Log In',
                onPressed: _handleSignIn,
                neonColor: AppColors.neonTeal,
              ),
              const SizedBox(height: 20),

              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.textGray)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(color: AppColors.textGray)),
                  ),
                  Expanded(child: Divider(color: AppColors.textGray)),
                ],
              ),
              const SizedBox(height: 20),

              // Note: The Google Sign-In button now calls the modified _handleGoogleSignIn
              NeonButton(
                text: 'Sign in with Google',
                onPressed: _handleGoogleSignIn,
                neonColor: AppColors.softBlue,
                icon: Icons.login,
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: AppColors.textGray)),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signup),
                    child: const Text('Sign Up', style: TextStyle(color: AppColors.electricPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Continue as Guest', style: TextStyle(color: AppColors.textGray, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}