import 'package:flutter/material.dart';
import 'package:livestream_platform/features/auth/presentation/pages/login_page.dart';
import 'package:livestream_platform/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:livestream_platform/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:livestream_platform/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/otp-verification':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationPage(
            phoneNumber: args['phoneNumber'],
            verificationId: args['verificationId'],
          ),
        );
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
