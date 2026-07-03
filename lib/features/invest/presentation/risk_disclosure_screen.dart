import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../domain/providers/lender_profile_provider.dart';

class RiskDisclosureScreen extends ConsumerStatefulWidget {
  const RiskDisclosureScreen({super.key});

  @override
  ConsumerState<RiskDisclosureScreen> createState() => _RiskDisclosureScreenState();
}

class _RiskDisclosureScreenState extends ConsumerState<RiskDisclosureScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isChecked = false;
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Check if the content is small enough to fit without scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent <= 0) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 20) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  void _onAgree() async {
    if (!_isChecked || _isSigning) return;

    setState(() => _isSigning = true);
    try {
      await ref.read(lenderProfileProvider.notifier).onboardLender('moderate');
      if (mounted) {
        context.go('/invest/dashboard');
      }
    } catch (_) {
      setState(() => _isSigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Risk Disclosure',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RBI MANDATED RISK DISCLOSURE STATEMENT',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('1. Capital Risk & Guarantees'),
                        _buildSectionBody(
                          'Lending on P2P/co-lending marketplaces involves capital risk. Peer-to-peer interest rates and principal payouts are NOT guaranteed by the Reserve Bank of India (RBI), the platform, or partners. There is a possibility that a borrower may default on interest or principal repayments.',
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTitle('2. Platform Operations & Licenses'),
                        _buildSectionBody(
                          'MacroFinance facilitates co-lending investments as an intermediary under partner NBFC licenses. The platform performs stringent automated and manual credit checks, KYC verification, and e-NACH setup on all borrowers to minimize default rates. However, lender returns are tied directly to borrower repayment behavior.',
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTitle('3. Diversification Advantage'),
                        _buildSectionBody(
                          'Lenders do not invest in individual borrower profiles directly. Contributions are aggregated into a pool and automatically distributed across numerous pre-screened borrower categories. This diversification minimizes individual borrower default impact on your overall portfolio.',
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTitle('4. TDS and Taxation rules'),
                        _buildSectionBody(
                          'Interest income earned from lending operations is taxable under the Income Tax Act, 1961 as "Income from Other Sources". Under Section 194A, Tax Deducted at Source (TDS) at the rate of 10% is applicable if the annual interest income credited to the wallet exceeds ₹5,000 in a financial year.',
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTitle('5. Early Exit Restrictions'),
                        _buildSectionBody(
                          'Depending on the plan tenure, early exit penalties may apply. Starter and Growth plans support early exit after 30 days subject to a 2.0% penalty deducted from the principal amount. Premium Plans are locked for the entire 12-month tenure with no early exit allowed.',
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Please scroll to the bottom to verify you have read these terms.',
                            style: AppTextStyles.caption.copyWith(
                              color: _hasScrolledToBottom ? AppColors.accent : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Checkbox & Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: isDark
                    ? const Border(top: BorderSide(color: AppColors.darkBorder))
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: _hasScrolledToBottom
                            ? (v) => setState(() => _isChecked = v ?? false)
                            : null,
                        activeColor: AppColors.accent,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _hasScrolledToBottom
                              ? () => setState(() => _isChecked = !_isChecked)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'I have read, understood, and accept the Risk Disclosure Agreement and terms of co-lending investments.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _hasScrolledToBottom
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isSigning
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : GradientButton(
                            text: 'I Agree & Continue',
                            onPressed: (_hasScrolledToBottom && _isChecked) ? _onAgree : null,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          height: 1.45,
        ),
      ),
    );
  }
}
