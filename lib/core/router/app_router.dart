import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/circle/presentation/screens/circle_screen.dart';
import '../../features/circle/presentation/screens/friend_vouches_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/contact_handshake_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/pro/presentation/screens/pro_dashboard_screen.dart';
import '../../features/pro/presentation/screens/lead_tracker_screen.dart';
import '../../features/safety/presentation/screens/safety_center_screen.dart';
import '../../features/safety/presentation/screens/report_alert_screen.dart';
import '../../features/safety/presentation/screens/trust_bundle_screen.dart';
import '../../features/scout/presentation/screens/scout_screen.dart';
import '../../features/vouch/presentation/screens/add_vouch_screen.dart';
import '../../features/vouch/presentation/screens/pro_profile_screen.dart';
import '../widgets/navigation_shell.dart';

/// App route paths.
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String contactHandshake = '/contact-handshake';
  static const String home = '/home';
  static const String circle = '/circle';
  static const String scout = '/scout';
  static const String profile = '/profile';
  static const String addVouch = '/add-vouch';
  static const String proProfile = '/pro/:proId';
  static const String friendVouches = '/friend/:friendId/vouches';
  static const String safetyCenter = '/safety';
  static const String reportAlert = '/safety/report';
  static const String trustBundle = '/trust-bundle';
  static const String proDashboard = '/pro-dashboard';
  static const String leadTracker = '/pro-dashboard/leads';
}

/// GoRouter configuration.
GoRouter createRouter({bool isAuthenticated = false, bool hasOnboarded = false}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAtSplash = location == AppRoutes.splash;

      if (isAtSplash) return null;

      if (!isAuthenticated) {
        final publicRoutes = [
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.otp,
        ];
        if (!publicRoutes.contains(location)) {
          return AppRoutes.login;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.contactHandshake,
        builder: (context, state) => const ContactHandshakeScreen(),
      ),
      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) => NavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.circle,
            builder: (context, state) => const CircleScreen(),
          ),
          GoRoute(
            path: AppRoutes.scout,
            builder: (context, state) => const ScoutScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addVouch,
        builder: (context, state) => const AddVouchScreen(),
      ),
      GoRoute(
        path: '/pro/:proId',
        builder: (context, state) {
          final proId = state.pathParameters['proId']!;
          return ProProfileScreen(proId: proId);
        },
      ),
      GoRoute(
        path: '/friend/:friendId/vouches',
        builder: (context, state) {
          final friendId = state.pathParameters['friendId']!;
          return FriendVouchesScreen(friendId: friendId);
        },
      ),
      GoRoute(
        path: AppRoutes.safetyCenter,
        builder: (context, state) => const SafetyCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportAlert,
        builder: (context, state) => const ReportAlertScreen(),
      ),
      GoRoute(
        path: AppRoutes.trustBundle,
        builder: (context, state) => const TrustBundleScreen(),
      ),
      GoRoute(
        path: AppRoutes.proDashboard,
        builder: (context, state) => const ProDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.leadTracker,
        builder: (context, state) => const LeadTrackerScreen(),
      ),
    ],
  );
}
