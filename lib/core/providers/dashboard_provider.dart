import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_service.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ApiService.getDashboard();
  return data;
});
