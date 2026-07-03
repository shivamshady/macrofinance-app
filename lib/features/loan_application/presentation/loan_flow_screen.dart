import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';
import 'step1_personal.dart';
import 'step2_pan.dart';
import 'step3_occupation.dart';
import 'step4_references.dart';
import 'step5_credit_check.dart';
import 'step6_kyc.dart';
import 'step7_loan_offer.dart';
import 'step8_bank.dart';
import 'step9_nach.dart';
import 'step10_esign.dart';
import 'step11_disbursement.dart';

/// Loan Flow Coordinator — routes to correct step based on state
class LoanFlowScreen extends ConsumerWidget {
  const LoanFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loanApplicationProvider);

    return switch (state.currentStep) {
      1 => const Step1PersonalScreen(),
      2 => const Step2PanScreen(),
      3 => const Step3OccupationScreen(),
      4 => const Step4ReferencesScreen(),
      5 => const Step5CreditCheckScreen(),
      6 => const Step6KycScreen(),
      7 => const Step7LoanOfferScreen(),
      8 => const Step8BankScreen(),
      9 => const Step9NachScreen(),
      10 => const Step10EsignScreen(),
      11 => const Step11DisbursementScreen(),
      _ => const Step1PersonalScreen(),
    };
  }
}
