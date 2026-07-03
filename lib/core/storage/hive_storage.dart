import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// MacroFinance v2 — Hive Local Storage
/// Offline cache + loan step persistence
class HiveStorage {
  static late Box _loanProgressBox;
  static late Box _userCacheBox;
  static late Box _settingsBox;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    _loanProgressBox = await Hive.openBox(AppConstants.hiveBoxLoanProgress);
    _userCacheBox = await Hive.openBox(AppConstants.hiveBoxUserCache);
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxSettings);
  }

  // ══════════════════════════════════════
  //  LOAN PROGRESS (step persistence)
  // ══════════════════════════════════════

  /// Save current loan application step
  static Future<void> saveLoanStep(int step) async {
    await _loanProgressBox.put('current_step', step);
  }

  /// Get last completed loan step (0 = not started)
  static int getLoanStep() {
    return _loanProgressBox.get('current_step', defaultValue: 0);
  }

  /// Save step data (form values) for a specific step
  static Future<void> saveStepData(int step, Map<String, dynamic> data) async {
    await _loanProgressBox.put('step_${step}_data', data);
  }

  /// Get step data for a specific step
  static Map<String, dynamic>? getStepData(int step) {
    final data = _loanProgressBox.get('step_${step}_data');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Clear all loan progress (after disbursement or cancellation)
  static Future<void> clearLoanProgress() async {
    await _loanProgressBox.clear();
  }

  /// Save active loan application ID
  static Future<void> saveActiveApplicationId(String id) async {
    await _loanProgressBox.put('active_application_id', id);
  }

  /// Get active loan application ID
  static String? getActiveApplicationId() {
    return _loanProgressBox.get('active_application_id');
  }

  // ══════════════════════════════════════
  //  USER CACHE
  // ══════════════════════════════════════

  /// Cache user profile data
  static Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await _userCacheBox.put('user_profile', profile);
  }

  /// Get cached user profile
  static Map<String, dynamic>? getCachedUserProfile() {
    final data = _userCacheBox.get('user_profile');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Cache user's current tier level
  static Future<void> cacheTierLevel(int level) async {
    await _userCacheBox.put('tier_level', level);
  }

  /// Get cached tier level
  static int getCachedTierLevel() {
    return _userCacheBox.get('tier_level', defaultValue: 1);
  }

  /// Cache credit score
  static Future<void> cacheCreditScore(int score) async {
    await _userCacheBox.put('credit_score', score);
    await _userCacheBox.put('credit_score_checked_at', DateTime.now().toIso8601String());
  }

  /// Get cached credit score
  static int? getCachedCreditScore() {
    return _userCacheBox.get('credit_score');
  }

  /// Clear user cache (on logout)
  static Future<void> clearUserCache() async {
    await _userCacheBox.clear();
  }

  // ══════════════════════════════════════
  //  APP SETTINGS
  // ══════════════════════════════════════

  /// Save theme mode ('light', 'dark', 'system')
  static Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put(AppConstants.keyThemeMode, mode);
  }

  /// Get theme mode
  static String getThemeMode() {
    return _settingsBox.get(AppConstants.keyThemeMode, defaultValue: 'light');
  }

  /// Save locale ('en', 'hi')
  static Future<void> saveLocale(String locale) async {
    await _settingsBox.put(AppConstants.keyLocale, locale);
  }

  /// Get locale
  static String getLocale() {
    return _settingsBox.get(AppConstants.keyLocale, defaultValue: 'en');
  }

  /// Close all boxes
  static Future<void> close() async {
    await _loanProgressBox.close();
    await _userCacheBox.close();
    await _settingsBox.close();
  }
}
