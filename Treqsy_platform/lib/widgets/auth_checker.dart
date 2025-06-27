import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/features/auth/login_screen.dart';
import 'package:treqsy_platform/features/auth/register_screen.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';
import 'package:treqsy_platform/features/auth/welcome_screen.dart';
import 'package:treqsy_platform/features/dashboard/admin_dashboard.dart';
import 'package:treqsy_platform/features/dashboard/host_home_screen.dart';
import 'package:treqsy_platform/features/dashboard/master_admin_dashboard.dart';
import 'package:treqsy_platform/features/dashboard/user_home_screen.dart';
import 'package:treqsy_platform/providers/ui_provider.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authScreen = ref.watch(authScreenProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.user != null) {
      // Role-based navigation
      switch (authState.user!.role) {
        case 'master_admin':
          return const MasterAdminDashboard();
        case 'admin':
          return const AdminDashboard();
        case 'host':
          return const HostHomeScreen();
        case 'user':
          return const UserHomeScreen();
        default:
          // Fallback for any other case
          return const UserHomeScreen();
      }
    } else {
      // Show auth flow screens
      switch (authScreen) {
        case AuthScreen.login:
          return const LoginScreen();
        case AuthScreen.register:
          return const RegisterScreen();
        default:
          return const WelcomeScreen();
      }
    }
  }
} 