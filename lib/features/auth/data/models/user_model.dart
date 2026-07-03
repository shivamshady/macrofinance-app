import '../../domain/entities/user.dart';

/// User data model — serialization layer
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    required super.role,
    required super.kycStatus,
    super.profileImageUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.borrower,
      ),
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == json['kyc_status'],
        orElse: () => KycStatus.notStarted,
      ),
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'kyc_status': kycStatus.name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Mock user for development
  static UserModel mockBorrower() {
    return UserModel(
      id: 'usr_001',
      name: 'Rahul Sharma',
      phone: '9876543210',
      email: 'rahul.sharma@email.com',
      role: UserRole.borrower,
      kycStatus: KycStatus.verified,
      createdAt: DateTime(2025, 6, 15),
    );
  }

  static UserModel mockLender() {
    return UserModel(
      id: 'usr_002',
      name: 'Priya Kapoor',
      phone: '9876543211',
      email: 'priya.kapoor@email.com',
      role: UserRole.lender,
      kycStatus: KycStatus.verified,
      createdAt: DateTime(2025, 5, 10),
    );
  }
}
