import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/data/auth/auth_model.dart';

// Represents the current user's state: Loading, Data (User), or Error.
typedef AuthState = AsyncValue<User?>;

// 1. The Notifier: Manages the state and business logic
class AuthNotifier extends StateNotifier<AuthState> {
  // Pass the initial state to the super constructor
  AuthNotifier() : super(const AuthState.loading()) {
    // Simulate checking the initial authentication state (e.g., from stored token)
    _initializeAuth();
  }

  // --- Simulated Core Logic ---

  Future<void> _simulateDelay() => Future.delayed(const Duration(seconds: 2));

  void _initializeAuth() async {
    await _simulateDelay();
    // In a real app, you would check a stored token or Firebase.
    // For the blueprint, we start as unauthenticated (null).
    // The 'state' property is now correctly recognized from StateNotifier.
    state = const AuthState.data(null);
  }

  // --- Public Authentication Methods ---

  Future<void> signIn(String email, String password) async {
    // Start loading state
    state = const AuthState.loading();

    await _simulateDelay();

    try {
      // Simulated sign-in success: Creates a non-premium mock user
      if (email.contains('premium')) {
        state = AuthState.data(User.mock(isPremium: true));
      } else {
        state = AuthState.data(User.mock(isPremium: false));
      }

    } catch (e, st) {
      // Simulated sign-in failure
      state = AuthState.error('Sign-in failed. Check credentials.', st);
      // Revert to unauthenticated state after error display
      await Future.delayed(const Duration(seconds: 3));
      state = const AuthState.data(null);
    }
  }

  Future<void> signUp(String email, String password) async {
    // Start loading state
    state = const AuthState.loading();

    await _simulateDelay();

    try {
      // Simulated sign-up success: Creates a new non-premium mock user
      state = AuthState.data(User.mock(isPremium: false));

    } catch (e, st) {
      // Simulated sign-up failure
      state = AuthState.error('Sign-up failed. User may already exist.', st);
      await Future.delayed(const Duration(seconds: 3));
      state = const AuthState.data(null);
    }
  }

  Future<void> signOut() async {
    // Start loading state
    state = const AuthState.loading();

    await _simulateDelay();

    // Set user to null, signifying logout
    state = const AuthState.data(null);
  }

  Future<void> forgotPassword(String email) async {
    // This function only needs to complete the operation (no state change required)
    await _simulateDelay();
    // Simulated email sent
  }
}

// 2. The Provider: Exposes the AuthNotifier to the rest of the application.
// This definition fixes the "Undefined function 'StateNotifierProvider'" error in other files.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
