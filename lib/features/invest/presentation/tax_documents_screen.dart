import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

class TaxDocumentsScreen extends ConsumerStatefulWidget {
  const TaxDocumentsScreen({super.key});

  @override
  ConsumerState<TaxDocumentsScreen> createState() => _TaxDocumentsScreenState();
}

class _TaxDocumentsScreenState extends ConsumerState<TaxDocumentsScreen> {
  String _selectedFY = '2024-25';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest/dashboard'),
        ),
        title: Text(
          'Tax Documents',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FY Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Financial Year', style: AppTextStyles.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFY,
                      underline: const SizedBox(),
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      items: const [
                        DropdownMenuItem(value: '2024-25', child: Text('FY 2024-25')),
                        DropdownMenuItem(value: '2025-26', child: Text('FY 2025-26')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedFY = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tax Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interest & TDS Summary',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Financial Year', 'FY $_selectedFY'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('Gross Interest Earned', '₹4,200.00'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('TDS Deducted (@10%)', '₹420.00', isError: true),
                    const Divider(height: 24),
                    _buildSummaryRow('Net Interest Payout', '₹3,780.00', isAccent: true, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Advice box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tax Filing Tip: You should declare this interest income under "Income from Other Sources" in your Income Tax Return (ITR).',
                        style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Documents List
              Text('Available Documents', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildDocumentItem(
                context,
                title: 'Form 16A (Quarterly TDS Certificate)',
                desc: 'Official certificate for tax deducted at source.',
                onDownload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Form 16A PDF...')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildDocumentItem(
                context,
                title: 'Interest Certificate',
                desc: 'Consolidated interest credit statement for FY $_selectedFY.',
                onDownload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Interest Certificate PDF...')),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isAccent = false, bool isError = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 13,
            fontWeight: (isBold || isAccent || isError) ? FontWeight.w700 : FontWeight.w500,
            color: isError ? AppColors.error : (isAccent ? AppColors.accent : (isBold ? AppColors.primary : null)),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(
    BuildContext context, {
    required String title,
    required String desc,
    required VoidCallback onDownload,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.accent),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
