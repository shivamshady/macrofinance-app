import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/investment_plan.dart';
import 'lender_profile_provider.dart';

final investmentPlansProvider = FutureProvider<List<InvestmentPlan>>((ref) async {
  final repository = ref.watch(investRepositoryProvider);
  return repository.getInvestmentPlans();
});
