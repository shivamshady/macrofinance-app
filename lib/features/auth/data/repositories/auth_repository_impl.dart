import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Auth repository implementation with mock data
/// Replace mock implementations with real API calls when backend is ready
class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<String> sendOtp(String phone) async {
    // Mock: Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // In production, call API to send OTP
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<User> verifyOtp(String phone, String otp, String sessionId) async {
    // Mock: Accept any 6-digit OTP
    await Future.delayed(const Duration(seconds: 1));

    if (otp.length != 6) {
      throw Exception('Invalid OTP');
    }

    // Mock: Return existing user or indicate new registration needed
    final existingUser = await _getStoredUser();
    if (existingUser != null) {
      await _secureStorage.write(
        key: AppConstants.keyAuthToken,
        value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      return existingUser;
    }

    // Store auth token
    await _secureStorage.write(
      key: AppConstants.keyAuthToken,
      value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Return mock user
    final user = UserModel.mockBorrower();
    await _storeUser(user);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String phone,
    required String email,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      role: role,
      kycStatus: KycStatus.notStarted,
      createdAt: DateTime.now(),
    );

    await _storeUser(user);
    await _secureStorage.write(
      key: AppConstants.keyAuthToken,
      value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await _secureStorage.write(
      key: AppConstants.keyUserRole,
      value: role.name,
    );

    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _getStoredUser();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    await _secureStorage.delete(key: AppConstants.keyUserId);
    await _secureStorage.delete(key: AppConstants.keyUserRole);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final value = await _secureStorage.read(
      key: AppConstants.keyOnboardingCompleted,
    );
    return value == 'true';
  }

  @override
  Future<void> completeOnboarding() async {
    await _secureStorage.write(
      key: AppConstants.keyOnboardingCompleted,
      value: 'true',
    );
  }

  // ── Private Helpers ──

  Future<UserModel?> _getStoredUser() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  Future<void> _storeUser(UserModel user) async {
    await _secureStorage.write(
      key: 'user_data',
      value: jsonEncode(user.toJson()),
    );
    await _secureStorage.write(key: AppConstants.keyUserId, value: user.id);
  }
}
