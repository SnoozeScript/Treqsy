import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthScreen {
  welcome,
  login,
  register,
}

final authScreenProvider = StateProvider<AuthScreen>((ref) => AuthScreen.welcome); 