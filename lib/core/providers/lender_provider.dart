import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_service.dart';
import '../../features/invest/domain/models/lender_profile.dart';

final lenderDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ApiService.getLenderDashboard();
});
