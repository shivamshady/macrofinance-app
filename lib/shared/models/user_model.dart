/// MacroFinance v2 — User Model
/// Matches PostgreSQL users table schema
class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? educationLevel;
  final String? alternatePhone;
  final String? profilePhotoUrl;
  final bool isActive;
  final bool isBlocked;
  final String? blockReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // KYC status (joined from user_kyc table)
  final KycStatus kycStatus;

  // Tier info (joined from user_loan_tiers table)
  final int currentTierLevel;
  final int loansRepaidOnTime;
  final int loansRepaidLate;
  final int loansDefaulted;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.educationLevel,
    this.alternatePhone,
    this.profilePhotoUrl,
    this.isActive = true,
    this.isBlocked = false,
    this.blockReason,
    required this.createdAt,
    required this.updatedAt,
    this.kycStatus = KycStatus.pending,
    this.currentTierLevel = 1,
    this.loansRepaidOnTime = 0,
    this.loansRepaidLate = 0,
    this.loansDefaulted = 0,
  });

  bool get isKycVerified => kycStatus == KycStatus.verified;
  bool get hasCompletedProfile => fullName != null && dateOfBirth != null;
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'] as String?,
      maritalStatus: json['marital_status'] as String?,
      educationLevel: json['education_level'] as String?,
      alternatePhone: json['alternate_phone'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kycStatus: KycStatus.fromString(json['kyc_status'] ?? 'pending'),
      currentTierLevel: json['current_tier_level'] as int? ?? 1,
      loansRepaidOnTime: json['loans_repaid_on_time'] as int? ?? 0,
      loansRepaidLate: json['loans_repaid_late'] as int? ?? 0,
      loansDefaulted: json['loans_defaulted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'marital_status': maritalStatus,
      'education_level': educationLevel,
      'alternate_phone': alternatePhone,
      'profile_photo_url': profilePhotoUrl,
      'is_active': isActive,
      'is_blocked': isBlocked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'kyc_status': kycStatus.value,
      'current_tier_level': currentTierLevel,
      'loans_repaid_on_time': loansRepaidOnTime,
      'loans_repaid_late': loansRepaidLate,
      'loans_defaulted': loansDefaulted,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    KycStatus? kycStatus,
    int? currentTierLevel,
    int? loansRepaidOnTime,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      maritalStatus: maritalStatus,
      educationLevel: educationLevel,
      alternatePhone: alternatePhone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isActive: isActive,
      isBlocked: isBlocked,
      blockReason: blockReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      kycStatus: kycStatus ?? this.kycStatus,
      currentTierLevel: currentTierLevel ?? this.currentTierLevel,
      loansRepaidOnTime: loansRepaidOnTime ?? this.loansRepaidOnTime,
      loansRepaidLate: loansRepaidLate,
      loansDefaulted: loansDefaulted,
    );
  }
}

/// KYC Status enum matching PostgreSQL CHECK constraint
enum KycStatus {
  pending('pending'),
  inProgress('in_progress'),
  verified('verified'),
  rejected('rejected'),
  expired('expired');

  final String value;
  const KycStatus(this.value);

  static KycStatus fromString(String s) {
    return KycStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => KycStatus.pending,
    );
  }
}
