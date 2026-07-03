import '../entities/user.dart';

/// Auth repository interface — domain contract
abstract class AuthRepository {
  /// Send OTP to phone number
  Future<String> sendOtp(String phone);

  /// Verify OTP and return auth token
  Future<User> verifyOtp(String phone, String otp, String sessionId);

  /// Register a new user
  Future<User> register({
    required String name,
    required String phone,
    required String email,
    required UserRole role,
  });

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Logout and clear tokens
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Check if onboarding is completed
  Future<bool> isOnboardingComplete();

  /// Mark onboarding as completed
  Future<void> completeOnboarding();
}
