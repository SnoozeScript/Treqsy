import 'package:flutter/material.dart';
import 'package:livestream_platform/core/constants/app_constants.dart';
import 'package:livestream_platform/core/routes/app_router.dart';
import 'package:livestream_platform/core/theme/app_theme.dart';
import 'package:livestream_platform/features/splash/presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize any services here (e.g., Firebase, Analytics, etc.)
  _initializeApp();
  
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  // Add any async initialization here
  // e.g., await Firebase.initializeApp();
  // e.g., await Hive.initFlutter();
  // e.g., await setupLocator(); // For dependency injection
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
      home: const SplashPage(),
      builder: (context, child) {
        return MediaQuery(
          // This ensures text scales uniformly on all devices
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
