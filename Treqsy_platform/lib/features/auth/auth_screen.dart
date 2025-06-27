import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/data/api_service.dart';
import 'package:treqsy_platform/features/auth/welcome_screen.dart';

// This screen is no longer used as the primary auth screen.
// It can be deleted or kept for reference. For now, I will clear it.
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Direct users to the new Welcome Screen flow.
    return const WelcomeScreen();
  }
} 