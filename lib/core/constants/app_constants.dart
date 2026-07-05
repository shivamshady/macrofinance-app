/// MacroFinance v2 — App Constants
/// Progressive loan system with ₹50,000 maximum
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'MacroFinance';
  static const String appTagline = 'Smart Lending. Smarter Returns.';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '1';

  // ── API ──
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // ── Loan Limits (v2: ₹50,000 max across all tiers) ──
  static const double minLoanAmount = 2000;
  static const double maxLoanAmount = 50000;
  static const int minTenureDays = 7;
  static const int maxTenureDays = 90;

  // ── Interest & Fees ──
  static const double defaultInterestRateMonthly = 2.5;    // % per month
  static const double defaultProcessingFeePct = 5.0;        // %
  static const double defaultInsuranceFeePct = 0.5;          // %
  static const double defaultLateFeeDaily = 0.5;             // % per day
  static const double gstPct = 18.0;                         // %

  // ── KYC ──
  static const int panLength = 10;
  static const int aadhaarLength = 12;
  static const int phoneLength = 10;
  static const int otpLength = 6;
  static const int ifscLength = 11;
  static const int otpExpirySeconds = 60;   // v2: 60s per Redis config
  static const int maxOtpAttempts = 3;
  static const int maxKycAttempts = 3;
  static const int creditScoreValidDays = 90;

  // ── Auth ──
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;
  static const int sessionTimeoutMinutes = 10;  // background timeout → MPIN re-auth
  static const int mpinLength = 4;

  // ── Investment (Lender) ──
  static const double minInvestmentAmount = 5000;
  static const double maxInvestmentAmount = 1000000;

  // ── Referral ──
  static const double referralCommissionPct = 10.0;  // 10% of processing fee

  // ── Storage Keys ──
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserRole = 'user_role';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyKycCompleted = 'kyc_completed';
  static const String keyMpinHash = 'mpin_hash';
  static const String keyDeviceId = 'device_id';
  static const String keyFcmToken = 'fcm_token';
  static const String keyLastActiveTime = 'last_active_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';

  // ── Hive Box Names ──
  static const String hiveBoxLoanProgress = 'loan_progress';
  static const String hiveBoxUserCache = 'user_cache';
  static const String hiveBoxSettings = 'app_settings';

  // ── Loan Application Steps ──
  static const int totalLoanSteps = 11;
  static const List<String> loanStepNames = [
    'Personal Details',     // Step 1
    'PAN Verification',     // Step 2
    'Occupation & Income',  // Step 3
    'References',           // Step 4
    'KYC Verification',     // Step 5
    'Credit Check',         // Step 6
    'Loan Offer',           // Step 7
    'Bank Verification',    // Step 8
    'e-NACH Setup',         // Step 9
    'e-Sign Agreement',     // Step 10
    'Disbursement',         // Step 11
  ];

  // ── Animations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // ── Pagination ──
  static const int pageSize = 20;

  // ── Min Tap Target (Accessibility) ──
  static const double minTapTarget = 48.0;
}
