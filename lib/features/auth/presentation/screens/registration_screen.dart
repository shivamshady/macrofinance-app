import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/secure_text_field.dart';

/// Registration screen — v2 (no BLoC), name, email, role selection
class RegistrationScreen extends StatefulWidget {
  final String phone;

  const RegistrationScreen({super.key, required this.phone});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

enum UserRoleChoice { borrower, lender }

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRoleChoice _selectedRole = UserRoleChoice.borrower;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedRole == UserRoleChoice.lender) {
      context.go('/home/lender');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                Text('Tell us about yourself',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    )),
                const SizedBox(height: 8),
                Text(
                  'This information helps us set up your account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: 36),

                // Name
                SecureTextField(
                  controller: _nameController,
                  labelText: 'Full Name (as per PAN)',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 20),

                // Email
                SecureTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 32),

                // Role Selection
                Text('I want to', style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Borrow',
                        subtitle: 'Get instant cash loans',
                        isSelected: _selectedRole == UserRoleChoice.borrower,
                        onTap: () =>
                            setState(() => _selectedRole = UserRoleChoice.borrower),
                        gradient: AppColors.primaryGradient,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Lend',
                        subtitle: 'Earn high returns',
                        isSelected: _selectedRole == UserRoleChoice.lender,
                        onTap: () =>
                            setState(() => _selectedRole = UserRoleChoice.lender),
                        gradient: AppColors.goldGradient,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can switch between borrower and lender modes anytime from settings.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 18),
                              const SizedBox(width: 8),
                              const Text('Create Account'),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Role selection card with gradient border
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final bool isDark;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? null
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          gradient: isSelected
              ? LinearGradient(
                  colors: gradient.colors
                      .map((c) => c.withValues(alpha: 0.12))
                      .toList(),
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? gradient.colors.first
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected ? gradient : null,
                color: isSelected
                    ? null
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: isSelected
                    ? gradient.colors.first
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
