import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// MacroFinance v2 — Secure Storage Wrapper
/// JWT tokens, MPIN hash, sensitive credentials
class SecureStorageWrapper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Auth Tokens ──
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return _storage.read(key: AppConstants.keyAuthToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.keyRefreshToken);
  }

  // ── User ID ──
  static Future<void> saveUserId(String id) async {
    await _storage.write(key: AppConstants.keyUserId, value: id);
  }

  static Future<String?> getUserId() async {
    return _storage.read(key: AppConstants.keyUserId);
  }

  // ── MPIN ──
  static Future<void> saveMpinHash(String hash) async {
    await _storage.write(key: AppConstants.keyMpinHash, value: hash);
  }

  static Future<String?> getMpinHash() async {
    return _storage.read(key: AppConstants.keyMpinHash);
  }

  static Future<bool> hasMpin() async {
    final hash = await getMpinHash();
    return hash != null && hash.isNotEmpty;
  }

  // ── Device ID ──
  static Future<void> saveDeviceId(String id) async {
    await _storage.write(key: AppConstants.keyDeviceId, value: id);
  }

  static Future<String?> getDeviceId() async {
    return _storage.read(key: AppConstants.keyDeviceId);
  }

  // ── FCM Token ──
  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: AppConstants.keyFcmToken, value: token);
  }

  static Future<String?> getFcmToken() async {
    return _storage.read(key: AppConstants.keyFcmToken);
  }

  // ── Biometric ──
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.keyBiometricEnabled);
    return value == 'true';
  }

  // ── Session Management ──
  static Future<void> saveLastActiveTime() async {
    await _storage.write(
      key: AppConstants.keyLastActiveTime,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  static Future<bool> isSessionExpired() async {
    final lastActive = await _storage.read(key: AppConstants.keyLastActiveTime);
    if (lastActive == null) return true;

    final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(lastActive),
    );
    final diff = DateTime.now().difference(lastActiveTime);
    return diff.inMinutes >= AppConstants.sessionTimeoutMinutes;
  }

  // ── Onboarding ──
  static Future<void> setOnboardingComplete() async {
    await _storage.write(key: AppConstants.keyOnboardingCompleted, value: 'true');
  }

  static Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: AppConstants.keyOnboardingCompleted);
    return value == 'true';
  }

  // ── Clear All (logout) ──
  static Future<void> clearAll() async {
    // Keep onboarding status and device ID
    final deviceId = await getDeviceId();
    final onboarding = await _storage.read(key: AppConstants.keyOnboardingCompleted);

    await _storage.deleteAll();

    if (deviceId != null) await saveDeviceId(deviceId);
    if (onboarding != null) {
      await _storage.write(key: AppConstants.keyOnboardingCompleted, value: onboarding);
    }
  }
}
