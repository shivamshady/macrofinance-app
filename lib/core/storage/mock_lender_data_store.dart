import 'package:hive_flutter/hive_flutter.dart';
import '../../features/invest/domain/models/lender_profile.dart';

class MockLenderDataStore {
  static final MockLenderDataStore _instance = MockLenderDataStore._internal();
  factory MockLenderDataStore() => _instance;
  MockLenderDataStore._internal();

  static Map<String, dynamic> personalDetails = {};
  static Map<String, dynamic> financialProfile = {};
  static Map<String, dynamic> kycDetails = {};
  static Map<String, dynamic> bankAccount = {};

  static LenderProfile? _currentLenderProfile;

  static LenderProfile? get currentLender {
    return _currentLenderProfile;
  }

  static set currentLender(LenderProfile? profile) {
    _currentLenderProfile = profile;
    if (profile != null) {
      final box = Hive.box('lender_storage');
      box.put('profile_usr_mock', profile.toJson());
    }
  }

  static Future<void> loadFromHive() async {
    final box = await Hive.openBox('lender_storage');
    final data = box.get('profile_usr_mock');
    if (data != null) {
      _currentLenderProfile = LenderProfile.fromJson(Map<String, dynamic>.from(data));
    } else {
      _currentLenderProfile = null;
    }
    
    final pData = box.get('lender_personal_details');
    personalDetails = pData != null ? Map<String, dynamic>.from(pData) : {};
    
    final fData = box.get('lender_financial_profile');
    financialProfile = fData != null ? Map<String, dynamic>.from(fData) : {};
    
    final kData = box.get('lender_kyc_details');
    kycDetails = kData != null ? Map<String, dynamic>.from(kData) : {};
    
    final bData = box.get('lender_bank_account');
    bankAccount = bData != null ? Map<String, dynamic>.from(bData) : {};
  }

  static Future<void> savePersonalDetails(Map<String, dynamic> data) async {
    personalDetails = data;
    final box = Hive.box('lender_storage');
    await box.put('lender_personal_details', data);
  }

  static Future<void> saveFinancialProfile(Map<String, dynamic> data) async {
    financialProfile = data;
    final box = Hive.box('lender_storage');
    await box.put('lender_financial_profile', data);
  }

  static Future<void> saveKycDetails(Map<String, dynamic> data) async {
    kycDetails = data;
    final box = Hive.box('lender_storage');
    await box.put('lender_kyc_details', data);
  }

  static Future<void> saveBankAccount(Map<String, dynamic> data) async {
    bankAccount = data;
    final box = Hive.box('lender_storage');
    await box.put('lender_bank_account', data);
  }

  static Future<void> clear() async {
    personalDetails.clear();
    financialProfile.clear();
    kycDetails.clear();
    bankAccount.clear();
    _currentLenderProfile = null;
    final box = Hive.box('lender_storage');
    await box.delete('profile_usr_mock');
    await box.delete('lender_personal_details');
    await box.delete('lender_financial_profile');
    await box.delete('lender_kyc_details');
    await box.delete('lender_bank_account');
  }
}
