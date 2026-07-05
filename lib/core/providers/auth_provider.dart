import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? role;

  AuthState({this.isAuthenticated = false, this.userId, this.role});

  AuthState copyWith({bool? isAuthenticated, String? userId, String? role}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final token = await _storage.read(key: AppConstants.keyAuthToken);
    final userId = await _storage.read(key: AppConstants.keyUserId);
    final role = await _storage.read(key: AppConstants.keyUserRole);
    if (token != null && userId != null) {
      state = AuthState(isAuthenticated: true, userId: userId, role: role);
    }
  }

  Future<void> login(String accessToken, String refreshToken, String userId, String role) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: accessToken);
    await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    await _storage.write(key: AppConstants.keyUserId, value: userId);
    await _storage.write(key: AppConstants.keyUserRole, value: role);
    state = AuthState(isAuthenticated: true, userId: userId, role: role);
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyUserRole);
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
