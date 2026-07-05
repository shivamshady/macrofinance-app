import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/loan_models.dart';

/// MacroFinance — Centralized API Service
class ApiService {
  static final Dio _dio = ApiClient().dio;

  // ═══════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return response.data;
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String phone, String otp, {String? deviceId, String? fcmToken}) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'platform': 'mobile',
    });
    return response.data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> setMpin(String userId, String mpin) async {
    final response = await _dio.post('/auth/set-mpin', data: {'userId': userId, 'mpin': mpin});
    return response.data;
  }

  static Future<Map<String, dynamic>> loginMpin(String phone, String mpin) async {
    final response = await _dio.post('/auth/login-mpin', data: {'phone': phone, 'mpin': mpin});
    return response.data;
  }

  // ═══════════════════════════════════════════
  //  BORROWER & KYC
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/borrower/profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get('/borrower/dashboard');
    return response.data;
  }

  static Future<Map<String, dynamic>> verifyPan(String pan) async {
    final response = await _dio.post('/kyc/pan/verify', data: {'pan': pan});
    return response.data;
  }

  static Future<Map<String, dynamic>> uploadKycDoc(String docType, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/kyc/upload/$docType', data: formData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _dio.get('/kyc/status');
    return response.data;
  }

  // ═══════════════════════════════════════════
  //  LOANS
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> startLoanApplication() async {
    final response = await _dio.post('/loans/application/start');
    return response.data;
  }

  static Future<Map<String, dynamic>> saveLoanStep(String id, int step, Map<String, dynamic> data) async {
    final response = await _dio.put('/loans/application/$id/step/$step', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getLoanHistory() async {
    final response = await _dio.get('/loans/history');
    return response.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getLoanApplication(String id) async {
    final response = await _dio.get('/loans/application/$id');
    return response.data;
  }

  // ═══════════════════════════════════════════
  //  REPAYMENTS
  // ═══════════════════════════════════════════
  static Future<List<dynamic>> getRepayments(String loanId) async {
    final response = await _dio.get('/repayments/$loanId');
    return response.data as List<dynamic>;
  }

  // ═══════════════════════════════════════════
  //  LENDER
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> getLenderDashboard() async {
    final response = await _dio.get('/lender/dashboard');
    return response.data;
  }

  static Future<List<dynamic>> getInvestmentPlans() async {
    final response = await _dio.get('/lender/plans');
    return response.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _dio.get('/wallet/balance');
    return response.data;
  }
}
