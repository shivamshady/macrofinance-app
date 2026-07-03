import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Notifications list and settings screens
class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ));
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8,
        itemBuilder: (context, index) {
          final notifications = [
            _NotifData('Loan Approved! 🎉', 'Your ₹10,000 loan has been approved', '2h ago', Icons.check_circle, AppColors.accent),
            _NotifData('Payment Due Soon', 'Your loan repayment of ₹10,750 is due in 3 days', '1d ago', Icons.warning_amber, AppColors.warning),
            _NotifData('Tier Upgrade! 🥉', 'Congratulations! You\'ve been upgraded to Bronze tier', '3d ago', Icons.trending_up, AppColors.tierBronze),
            _NotifData('Referral Reward', 'You earned ₹50 from a referral', '5d ago', Icons.card_giftcard, AppColors.accent),
            _NotifData('KYC Verified', 'Your identity verification is complete', '1w ago', Icons.verified, AppColors.accent),
            _NotifData('New Loan Offer', 'You\'re eligible for up to ₹15,000', '1w ago', Icons.local_offer, AppColors.primary),
            _NotifData('Payment Received', 'We received your payment of ₹5,250', '2w ago', Icons.payment, AppColors.accent),
            _NotifData('Welcome! 🌱', 'Welcome to MacroFinance. Start your journey with Starter tier.', '3w ago', Icons.waving_hand, AppColors.primary),
          ];

          final n = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark ? null : AppColors.cardShadow,
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: n.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(n.icon, size: 20, color: n.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(n.subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                      const SizedBox(height: 4),
                      Text(n.time, style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotifData {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  _NotifData(this.title, this.subtitle, this.time, this.icon, this.color);
}

/// Notification Settings Screen
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _emailEnabled = false;
  bool _loanUpdates = true;
  bool _paymentReminders = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Channels', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(title: Text('Push Notifications', style: GoogleFonts.inter(fontSize: 14)), value: _pushEnabled, onChanged: (v) => setState(() => _pushEnabled = v), activeColor: AppColors.accent),
          SwitchListTile(title: Text('SMS', style: GoogleFonts.inter(fontSize: 14)), value: _smsEnabled, onChanged: (v) => setState(() => _smsEnabled = v), activeColor: AppColors.accent),
          SwitchListTile(title: Text('Email', style: GoogleFonts.inter(fontSize: 14)), value: _emailEnabled, onChanged: (v) => setState(() => _emailEnabled = v), activeColor: AppColors.accent),
          const SizedBox(height: 16),
          Text('Categories', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(title: Text('Loan Updates', style: GoogleFonts.inter(fontSize: 14)), value: _loanUpdates, onChanged: (v) => setState(() => _loanUpdates = v), activeColor: AppColors.accent),
          SwitchListTile(title: Text('Payment Reminders', style: GoogleFonts.inter(fontSize: 14)), value: _paymentReminders, onChanged: (v) => setState(() => _paymentReminders = v), activeColor: AppColors.accent),
          SwitchListTile(title: Text('Promotions & Offers', style: GoogleFonts.inter(fontSize: 14)), value: _promotions, onChanged: (v) => setState(() => _promotions = v), activeColor: AppColors.accent),
        ],
      ),
    );
  }
}
