import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/registration_details_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/mpin_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/kyc/presentation/screens/kyc_home_screen.dart';
import '../../features/loan_application/presentation/loan_flow_screen.dart';
import '../../features/borrower/presentation/screens/kfs_screen.dart';
import '../../features/compliance/presentation/screens/compliance_screen.dart';
import '../../features/repayment/presentation/screens/repay_screen.dart';
import '../../features/referral/presentation/screens/refer_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'bottom_nav_shell.dart';
import '../../features/invest/presentation/invest_landing_screen.dart';
import '../../features/invest/presentation/lender_onboarding_screen.dart';
import '../../features/invest/presentation/risk_disclosure_screen.dart';
import '../../features/invest/presentation/lender_dashboard_screen.dart';
import '../../features/invest/presentation/investment_plans_screen.dart';
import '../../features/invest/presentation/plan_detail_screen.dart';
import '../../features/invest/presentation/invest_now_screen.dart';
import '../../features/invest/presentation/invest_confirm_screen.dart';
import '../../features/invest/presentation/invest_success_screen.dart';
import '../../features/invest/presentation/portfolio_screen.dart';
import '../../features/invest/presentation/investment_detail_screen.dart';
import '../../features/invest/presentation/wallet_screen.dart';
import '../../features/invest/presentation/add_funds_screen.dart';
import '../../features/invest/presentation/withdraw_screen.dart';
import '../../features/invest/presentation/returns_history_screen.dart';
import '../../features/invest/presentation/tax_documents_screen.dart';
import '../../features/invest/presentation/loan_book_health_screen.dart';
import '../../features/invest/presentation/lender_referral_screen.dart';
import '../../features/invest/presentation/admin/admin_dashboard_screen.dart';
import '../../features/invest/presentation/admin/admin_withdrawals_screen.dart';
import '../../features/invest/presentation/admin/admin_plans_screen.dart';
import '../../features/invest/presentation/admin/admin_plan_edit_screen.dart';
import '../../features/invest/presentation/admin/admin_health_screen.dart';


/// MacroFinance v2 — Router configuration
/// All new routes for 11-step loan flow, repayment, referral, support, MPIN
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── Splash ──
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ──
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingScreen(
          onComplete: () => GoRouter.of(context).go('/login'),
        ),
      ),

      // ══════════════════════════════════════
      //  AUTH
      // ══════════════════════════════════════
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final extras = state.extra as Map<String, String>? ?? {};
          return OtpScreen(
            phone: extras['phone'] ?? '',
            sessionId: extras['sessionId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return RegistrationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/register/details',
        name: 'registerDetails',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return RegistrationDetailsScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/role-select',
        name: 'roleSelect',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return RoleSelectScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/mpin',
        name: 'mpin',
        builder: (context, state) {
          final isSetup = state.extra as bool? ?? false;
          return MpinScreen(isSetup: isSetup);
        },
      ),
      GoRoute(
        path: '/mpin/setup',
        name: 'mpinSetup',
        builder: (context, state) => const MpinScreen(isSetup: true),
      ),

      // ══════════════════════════════════════
      //  MAIN APP (Bottom Nav)
      // ══════════════════════════════════════
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const BottomNavShell(),
      ),
      GoRoute(
        path: '/home/lender',
        name: 'homeLender',
        builder: (context, state) => const BottomNavShell(isLender: true),
      ),

      // ══════════════════════════════════════
      //  KYC
      // ══════════════════════════════════════
      GoRoute(
        path: '/kyc',
        name: 'kyc',
        builder: (context, state) => const KycHomeScreen(),
      ),

      // ══════════════════════════════════════
      //  LOAN APPLICATION (11-step)
      // ══════════════════════════════════════
      GoRoute(
        path: '/loan/apply',
        name: 'loanApply',
        builder: (context, state) => const LoanFlowScreen(),
      ),
      GoRoute(
        path: '/loan/kfs',
        name: 'kfs',
        builder: (context, state) => const KfsScreen(),
      ),

      // ══════════════════════════════════════
      //  REPAYMENT
      // ══════════════════════════════════════
      GoRoute(
        path: '/repay',
        name: 'repay',
        builder: (context, state) => const RepayScreen(),
      ),
      GoRoute(
        path: '/repay/history',
        name: 'paymentHistory',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),

      // ══════════════════════════════════════
      //  REFERRAL
      // ══════════════════════════════════════
      GoRoute(
        path: '/refer',
        name: 'refer',
        builder: (context, state) => const ReferScreen(),
      ),

      // ══════════════════════════════════════
      //  SUPPORT
      // ══════════════════════════════════════
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),

      // ══════════════════════════════════════
      //  NOTIFICATIONS
      // ══════════════════════════════════════
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),

      // ══════════════════════════════════════
      //  COMPLIANCE
      // ══════════════════════════════════════
      GoRoute(
        path: '/compliance',
        name: 'compliance',
        builder: (context, state) => const ComplianceScreen(),
      ),

      // ══════════════════════════════════════
      //  PROFILE
      // ══════════════════════════════════════
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ══════════════════════════════════════
      //  INVESTMENT MODULE
      // ══════════════════════════════════════
      GoRoute(
        path: '/invest',
        builder: (context, state) => const InvestLandingScreen(),
      ),
      GoRoute(
        path: '/invest/onboarding',
        builder: (context, state) => const LenderOnboardingScreen(),
      ),
      GoRoute(
        path: '/invest/dashboard',
        builder: (context, state) => const LenderDashboardScreen(),
      ),
      GoRoute(
        path: '/invest/plans',
        builder: (context, state) => const InvestmentPlansScreen(),
      ),
      GoRoute(
        path: '/invest/plan/:id',
        builder: (context, state) => PlanDetailScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/invest/now/:id',
        builder: (context, state) => InvestNowScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/invest/confirm',
        builder: (context, state) => const InvestConfirmScreen(),
      ),
      GoRoute(
        path: '/invest/success',
        builder: (context, state) => const InvestSuccessScreen(),
      ),
      GoRoute(
        path: '/invest/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/invest/portfolio/:id',
        builder: (context, state) => InvestmentDetailScreen(investmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/invest/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/invest/wallet/add',
        builder: (context, state) => const AddFundsScreen(),
      ),
      GoRoute(
        path: '/invest/wallet/withdraw',
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: '/invest/returns',
        builder: (context, state) => const ReturnsHistoryScreen(),
      ),
      GoRoute(
        path: '/invest/tax',
        builder: (context, state) => const TaxDocumentsScreen(),
      ),
      GoRoute(
        path: '/invest/health',
        builder: (context, state) => const LoanBookHealthScreen(),
      ),
      GoRoute(
        path: '/invest/referral',
        builder: (context, state) => const LenderReferralScreen(),
      ),
      GoRoute(
        path: '/invest/risk-disclosure',
        builder: (context, state) => const RiskDisclosureScreen(),
      ),
      
      // ══════════════════════════════════════
      //  ADMIN PANEL ROUTES
      // ══════════════════════════════════════
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/withdrawals',
        builder: (context, state) => const AdminWithdrawalsScreen(),
      ),
      GoRoute(
        path: '/admin/plans',
        builder: (context, state) => const AdminPlansScreen(),
      ),
      GoRoute(
        path: '/admin/plans/edit/:id',
        builder: (context, state) => AdminPlanEditScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin/health',
        builder: (context, state) => const AdminHealthScreen(),
      ),
    ],
  );
}
