import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/constants/app_constants.dart';

class RoleSelectScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const RoleSelectScreen({
    super.key,
    required this.registrationData,
  });

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (_selectedRole == null) return;
    
    setState(() => _isLoading = true);

    try {
      final payload = Map<String, dynamic>.from(widget.registrationData);
      payload['role'] = _selectedRole;

      final response = await ApiService.register(payload);
      
      if (response['success'] == true) {
        const storage = FlutterSecureStorage();
        await storage.write(key: AppConstants.keyAuthToken, value: response['accessToken']);
        await storage.write(key: AppConstants.keyUserId, value: response['userId'].toString());
        await storage.write(key: AppConstants.keyUserPhone, value: payload['phone'].toString());
        await storage.write(key: AppConstants.keyUserRole, value: _selectedRole);

        if (!mounted) return;
        setState(() => _isLoading = false);
        
        final mpinOk = await context.push<bool>('/mpin', extra: true); // isSetup = true
        if (mpinOk == true) {
          if (!mounted) return;
          if (_selectedRole == 'lender') {
            context.go('/home/lender');
          } else {
            context.go('/home');
          }
        }
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete registration')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              const Text(
                'How would you like to use MacroFinance?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Choose your primary profile. You can always change this later in settings.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              _buildRoleCard(
                role: 'borrower',
                title: 'I want to Borrow',
                subtitle: 'Get instant loans up to ₹50,000 with low interest rates.',
                icon: Icons.account_balance_wallet_outlined,
              ),
              
              const SizedBox(height: 20),
              
              _buildRoleCard(
                role: 'lender',
                title: 'I want to Invest',
                subtitle: 'Earn up to 12% p.a. returns by funding verified borrowers.',
                icon: Icons.trending_up_rounded,
              ),
              
              const Spacer(),
              
              AppButton(
                label: 'Continue',
                isDisabled: _selectedRole == null || _isLoading,
                onPressed: _handleContinue,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
