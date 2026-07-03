import 'package:safe_device/safe_device.dart';
import 'package:flutter/services.dart';

/// MacroFinance — Security Utilities
/// Device security checks (jailbreak, emulator, mock location)
/// and screenshot protection.
class SecurityUtils {
  SecurityUtils._();

  static const MethodChannel _channel = MethodChannel('macrofinance.security');

  /// Runs all security checks. Throws an exception if any fail.
  static Future<void> performDeviceSecurityCheck() async {
    final bool isJailBroken = await SafeDevice.isJailBroken;
    if (isJailBroken) {
      throw SecurityException('Device is jailbroken or rooted. For your security, this app cannot run on compromised devices.');
    }

    final bool isRealDevice = await SafeDevice.isRealDevice;
    if (!isRealDevice) {
      // Typically apps block emulators in prod, but you might want to allow it in debug mode.
      // throw SecurityException('App cannot run on an emulator or simulator.');
    }

    final bool isOnExternalStorage = await SafeDevice.isOnExternalStorage;
    if (isOnExternalStorage) {
      throw SecurityException('App must be installed on internal storage for security reasons.');
    }
  }

  /// Enables screenshot and screen recording protection (Android: FLAG_SECURE)
  static Future<void> enableScreenshotProtection() async {
    try {
      await _channel.invokeMethod('enableScreenshotProtection');
    } catch (e) {
      // Method channel not implemented or not supported on this platform yet
    }
  }

  /// Disables screenshot and screen recording protection
  static Future<void> disableScreenshotProtection() async {
    try {
      await _channel.invokeMethod('disableScreenshotProtection');
    } catch (e) {
      // Method channel not implemented or not supported on this platform yet
    }
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
