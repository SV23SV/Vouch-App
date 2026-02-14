import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/privacy_service.dart';

/// Auth state for the application.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? phoneNumber;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.phoneNumber,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? phoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

/// Provides the Supabase service instance.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provides the Privacy service instance.
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService();
});

/// Auth state notifier.
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  final PrivacyService _privacyService;

  AuthNotifier(this._supabaseService, this._privacyService)
      : super(const AuthState());

  /// Checks if the user is already authenticated.
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      if (_supabaseService.isAuthenticated) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: _supabaseService.client.auth.currentUser,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sends OTP to the given phone number.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phoneNumber: phone);
    try {
      await _supabaseService.signInWithPhone(phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send verification code. Please try again.',
      );
    }
  }

  /// Verifies the OTP and signs in.
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final phone = state.phoneNumber;
      if (phone == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Phone number not found. Please try again.',
        );
        return false;
      }

      final response = await _supabaseService.verifyOtp(
        phone: phone,
        token: otp,
      );

      if (response.user != null) {
        // Create or update user profile with hashed phone
        final phoneHash = _privacyService.hashContact(phone);
        await _createOrUpdateUser(response.user!.id, phoneHash);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid verification code.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification failed. Please try again.',
      );
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _supabaseService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _createOrUpdateUser(String userId, String phoneHash) async {
    try {
      await _supabaseService.client.from('users').upsert({
        'id': userId,
        'phone_hash': phoneHash,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // User might already exist, which is fine
    }
  }
}

/// Auth provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final privacy = ref.watch(privacyServiceProvider);
  return AuthNotifier(supabase, privacy);
});
