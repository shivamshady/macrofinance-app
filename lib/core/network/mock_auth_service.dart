import 'package:flutter/foundation.dart';
import '../storage/mock_data_store.dart';
import '../../shared/models/user_model.dart';

class AuthResponse {
  final bool success;
  final String? error;
  final String? role;
  final bool? isNewUser;

  AuthResponse({required this.success, this.error, this.role, this.isNewUser});
}

class MockAuthService {
  static Future<AuthResponse> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Remove formatting
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    if (cleanPhone == '6200854150') {
      return AuthResponse(success: true); // Admin
    }
    
    if (cleanPhone.length == 10) {
      return AuthResponse(success: true);
    }
    
    return AuthResponse(success: false, error: 'Invalid phone number format');
  }

  static Future<AuthResponse> verifyOtp(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    if (code == '123456' || code == '000000') {
      if (cleanPhone == '6200854150') {
        // Admin login
        MockDataStore().currentUser = UserModel(
          id: 'admin_1',
          phone: cleanPhone,
          fullName: 'System Admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return AuthResponse(success: true, role: 'admin', isNewUser: false);
      }
      
      // Check if user exists in MockDataStore
      try {
        final existingUser = MockDataStore().allUsers.firstWhere((u) => u.phone == cleanPhone);
        MockDataStore().currentUser = existingUser;
        // In a real app, role would be determined here, we'll assume borrower for existing mock users unless specified
        return AuthResponse(success: true, role: 'borrower', isNewUser: false);
      } catch (e) {
        // User not found, is new
        return AuthResponse(success: true, role: 'none', isNewUser: true);
      }
    }
    
    return AuthResponse(success: false, error: 'Invalid OTP code');
  }

  static Future<AuthResponse> resendOtp(String phone) async {
    return sendOtp(phone);
  }
}
