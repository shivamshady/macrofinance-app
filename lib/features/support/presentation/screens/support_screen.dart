import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Support — FAQ, Chat, Ticket screens
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact options
            _SupportCard(
              icon: Icons.chat_bubble_outline,
              title: 'Chat with Us',
              subtitle: 'Get instant help from our team',
              color: AppColors.primary,
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SupportCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'grievance@macrofinance.in',
              color: AppColors.accent,
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SupportCard(
              icon: Icons.confirmation_number_outlined,
              title: 'Raise a Ticket',
              subtitle: 'Track your support request',
              color: AppColors.warning,
              isDark: isDark,
              onTap: () {},
            ),

            const SizedBox(height: 28),

            Text('Frequently Asked Questions', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            )),
            const SizedBox(height: 14),

            _FaqItem(question: 'How does the tier system work?',
              answer: 'You start at Tier 1 (Starter) with loans up to ₹5,000. Repay on time to unlock higher tiers with larger loan amounts, up to ₹50,000 at Gold tier.', isDark: isDark),
            _FaqItem(question: 'What is the maximum loan amount?',
              answer: 'The maximum loan amount is ₹50,000, available at Gold tier after repaying 3 loans on time with a credit score of 700+.', isDark: isDark),
            _FaqItem(question: 'How is interest calculated?',
              answer: 'Interest is charged at 2.5% per month on the loan amount. A processing fee of 5% + 18% GST is deducted upfront.', isDark: isDark),
            _FaqItem(question: 'What happens if I miss a payment?',
              answer: '1 late payment results in a warning. 2 consecutive late payments may cause a tier downgrade. Default (>90 days overdue) locks you to Tier 1.', isDark: isDark),
            _FaqItem(question: 'How do I contact the grievance officer?',
              answer: 'Email: grievance@macrofinance.in. You can also file a complaint on the RBI CMS portal.', isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SupportCard({required this.icon, required this.title, required this.subtitle,
    required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? null : AppColors.cardShadow,
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextTertiary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question, answer;
  final bool isDark;
  const _FaqItem({required this.question, required this.answer, required this.isDark});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isDark ? null : AppColors.cardShadow,
        border: widget.isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: ExpansionTile(
        title: Text(widget.question, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        children: [
          Text(widget.answer, style: GoogleFonts.inter(
            fontSize: 13, height: 1.5,
            color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
        ],
      ),
    );
  }
}
