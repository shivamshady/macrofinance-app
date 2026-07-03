import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_health.dart';
import 'lender_profile_provider.dart';

final platformHealthProvider = FutureProvider<PlatformHealth>((ref) async {
  final repository = ref.watch(investRepositoryProvider);
  return repository.getPlatformHealth();
});
