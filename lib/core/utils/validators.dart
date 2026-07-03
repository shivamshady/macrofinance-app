/// MacroFinance — Input Validators
/// PAN, Aadhaar, Phone, IFSC, Email, and financial validators
class Validators {
  Validators._();

  /// Validates Indian mobile number (10 digits, starts with 6-9)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) return 'Enter a valid 10-digit phone number';
    if (!RegExp(r'^[6-9]').hasMatch(cleaned)) return 'Phone number must start with 6-9';
    return null;
  }

  /// Validates PAN card number (ABCDE1234F format)
  static String? pan(String? value) {
    if (value == null || value.isEmpty) return 'PAN number is required';
    final upper = value.toUpperCase().trim();
    if (upper.length != 10) return 'PAN must be 10 characters';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(upper)) {
      return 'Enter a valid PAN (e.g., ABCDE1234F)';
    }
    return null;
  }

  /// Validates Aadhaar number (12 digits, starts with 2-9)
  static String? aadhaar(String? value) {
    if (value == null || value.isEmpty) return 'Aadhaar number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 12) return 'Aadhaar must be 12 digits';
    if (!RegExp(r'^[2-9]').hasMatch(cleaned)) return 'Enter a valid Aadhaar number';
    return null;
  }

  /// Validates IFSC code (4 letters + 0 + 6 alphanumeric)
  static String? ifsc(String? value) {
    if (value == null || value.isEmpty) return 'IFSC code is required';
    final upper = value.toUpperCase().trim();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(upper)) {
      return 'Enter a valid IFSC code (e.g., SBIN0001234)';
    }
    return null;
  }

  /// Validates email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates OTP (6 digits)
  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit OTP';
    }
    return null;
  }

  /// Validates name (min 2 characters, alphabets and spaces only)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates bank account number (9-18 digits)
  static String? bankAccount(String? value) {
    if (value == null || value.isEmpty) return 'Account number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 9 || cleaned.length > 18) {
      return 'Enter a valid account number (9-18 digits)';
    }
    return null;
  }

  /// Validates loan amount within limits
  static String? loanAmount(String? value, {double min = 5000, double max = 500000}) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Enter a valid amount';
    if (amount < min) return 'Minimum amount is ₹${min.toInt()}';
    if (amount > max) return 'Maximum amount is ₹${max.toInt()}';
    return null;
  }

  /// Generic required field validator
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Masks Aadhaar to show only last 4 digits (RBI compliance)
  static String maskAadhaar(String aadhaar) {
    final cleaned = aadhaar.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 12) return aadhaar;
    return 'XXXX XXXX ${cleaned.substring(8)}';
  }

  /// Masks PAN to show partial (ABC**1234*)
  static String maskPan(String pan) {
    if (pan.length != 10) return pan;
    return '${pan.substring(0, 3)}**${pan.substring(5, 9)}*';
  }
}
