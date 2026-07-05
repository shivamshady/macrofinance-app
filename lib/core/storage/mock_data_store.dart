import 'package:flutter/foundation.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/loan_models.dart';

class MockDataStore {
  // Singleton instance
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  MockDataStore._internal();

  UserModel? currentUser;
  
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1', 
      title: 'Welcome to MacroFinance!', 
      message: 'Complete your KYC to start investing or borrowing.', 
      date: DateTime.now().subtract(const Duration(hours: 2)), 
      isRead: false
    ),
  ];

  LoanApplicationModel? activeLoan;
  List<LoanApplicationModel> loanHistory = [];
  List<TransactionModel> transactions = [];
  
  List<UserModel> allUsers = [];
  
  List<String> usedPans = ['ABCDE1234F'];
  List<String> referralCodes = ['MACRO10', 'REF50', 'LEND50', 'SHIVAM50', 'WELCOME10'];
  
  bool nachSetup = false;
  
  // Lender fields
  double portfolioValue = 847500.0;
  double totalReturns = 97500.0;
  double returnRate = 12.5;

  void addNotification(String title, String message) {
    notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: DateTime.now(),
      isRead: false,
    ));
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}
