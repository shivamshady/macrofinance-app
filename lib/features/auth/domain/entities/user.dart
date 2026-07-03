import 'package:equatable/equatable.dart';

/// User entity — core domain model
class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final KycStatus kycStatus;
  final String? profileImageUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.kycStatus,
    this.profileImageUrl,
    required this.createdAt,
  });

  bool get isKycComplete => kycStatus == KycStatus.verified;
  bool get isBorrower => role == UserRole.borrower;
  bool get isLender => role == UserRole.lender;

  @override
  List<Object?> get props => [id, name, phone, email, role, kycStatus];
}

enum UserRole {
  borrower,
  lender,
}

enum KycStatus {
  notStarted,
  inProgress,
  submitted,
  verified,
  rejected,
}
