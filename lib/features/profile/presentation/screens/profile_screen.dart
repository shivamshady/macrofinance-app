import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/tier_badge.dart';

/// Profile screen — v2 with interactive avatar uploads, tier display, and logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _changeAvatar() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully.'), backgroundColor: AppColors.accent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + Name Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : AppColors.cardShadow,
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.primarySurface,
                          backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                          child: _avatarBytes == null
                              ? Text(
                                  'RS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Rahul Sharma',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 98765 43210',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TierBadge(tierLevel: 2),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings sections
            _SettingsSection(
              title: 'Account',
              items: [
                _SettingsItem(icon: Icons.person_outline, label: 'Personal Details', onTap: () {}),
                _SettingsItem(icon: Icons.account_balance_outlined, label: 'Bank Accounts', onTap: () {}),
                _SettingsItem(icon: Icons.verified_user_outlined, label: 'KYC Status', badge: 'Verified', badgeColor: AppColors.accent, onTap: () {}),
                _SettingsItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Switch to Investor Mode',
                  onTap: () => context.go('/home/lender'),
                ),
                _SettingsItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Switch to Admin Portal',
                  onTap: () => context.go('/admin/dashboard'),
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _SettingsSection(
              title: 'Security',
              items: [
                _SettingsItem(icon: Icons.pin_outlined, label: 'Change MPIN', onTap: () {}),
                _SettingsItem(icon: Icons.fingerprint, label: 'Biometric Login', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.accent), onTap: () {}),
                _SettingsItem(icon: Icons.lock_outline, label: 'Session Timeout', badge: '10 min', onTap: () {}),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _SettingsSection(
              title: 'Preferences',
              items: [
                _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Dark Mode', trailing: Switch(value: isDark, onChanged: (_) {}, activeColor: AppColors.accent), onTap: () {}),
                _SettingsItem(icon: Icons.language, label: 'Language', badge: 'English', onTap: () {}),
                _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _SettingsSection(
              title: 'Legal',
              items: [
                _SettingsItem(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
                _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                _SettingsItem(icon: Icons.gavel_outlined, label: 'Grievance Redressal', onTap: () {}),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text('Logout', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'MacroFinance v2.0.0',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  final bool isDark;

  const _SettingsSection({required this.title, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMedium.copyWith(
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, size: 22, color: AppColors.primary),
                    title: Text(item.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: item.trailing ?? (item.badge != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (item.badgeColor ?? AppColors.primary).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item.badge!, style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: item.badgeColor ?? AppColors.primary,
                            )),
                          )
                        : const Icon(Icons.chevron_right, size: 20, color: AppColors.lightTextTertiary)),
                    onTap: item.onTap,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.trailing,
    required this.onTap,
  });
}
