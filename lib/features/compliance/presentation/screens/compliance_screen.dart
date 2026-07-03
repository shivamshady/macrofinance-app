import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/regulatory_constants.dart';
import '../../../../core/widgets/glass_card.dart';

/// Compliance & Grievance screens
class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Compliance & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NBFC Info
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lending Partner',
                                style: AppTextStyles.caption),
                            Text(RegulatoryConstants.nbfcName,
                                style: AppTextStyles.titleSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow('Registration No.',
                      RegulatoryConstants.nbfcRegistrationNumber),
                  _InfoRow('Registered With',
                      RegulatoryConstants.nbfcRegisteredWith),
                  _InfoRow('Category', RegulatoryConstants.nbfcCategory),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu items
            _MenuItem(
              icon: Icons.shield_outlined,
              title: 'Data Consent Management',
              subtitle: 'View & manage your data permissions',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.gavel_outlined,
              title: 'Terms of Service',
              subtitle: 'Terms and conditions',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.support_agent_outlined,
              title: 'Grievance Redressal',
              subtitle: 'File a complaint',
              onTap: () => _showGrievanceSheet(context),
            ),
            _MenuItem(
              icon: Icons.delete_outline_rounded,
              title: 'Request Data Deletion',
              subtitle: 'DPDP Act 2023 compliance',
              onTap: () {},
              isDestructive: true,
            ),
            _MenuItem(
              icon: Icons.open_in_new_rounded,
              title: 'RBI DLA Directory',
              subtitle: 'Verify our app on RBI portal',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Data Policy
            Text('DATA COLLECTION POLICY', style: AppTextStyles.overline),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data We Collect',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.success,
                      )),
                  const SizedBox(height: 10),
                  ...RegulatoryConstants.permittedDataCollection.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 10),
                          Expanded(
                              child:
                                  Text(item, style: AppTextStyles.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                      color: AppColors.surfaceBorder, height: 24),
                  Text('Data We NEVER Access',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.error,
                      )),
                  const SizedBox(height: 10),
                  ...RegulatoryConstants.prohibitedDataAccess.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                              child:
                                  Text(item, style: AppTextStyles.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showGrievanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Grievance Redressal', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),

            _GrievanceRow(Icons.person_outlined,
                'Officer', RegulatoryConstants.nodalOfficerName),
            _GrievanceRow(Icons.email_outlined,
                'Email', RegulatoryConstants.nodalOfficerEmail),
            _GrievanceRow(Icons.phone_outlined,
                'Phone', RegulatoryConstants.nodalOfficerPhone),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'If your complaint is not resolved within ${RegulatoryConstants.grievanceResolutionDays} '
                'days, you can escalate to the RBI Complaints Management System (CMS) portal.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.warning,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('File a Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 4, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(
            flex: 5,
            child: Text(value,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.errorSurface
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDestructive ? AppColors.error : AppColors.textSecondary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textTertiary,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        tileColor: AppColors.surface,
      ),
    );
  }
}

class _GrievanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GrievanceRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
