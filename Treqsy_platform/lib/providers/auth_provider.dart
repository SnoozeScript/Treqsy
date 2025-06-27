import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:treqsy_platform/models/user_model.dart';
import 'package:treqsy_platform/data/api_service.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isLoading;

  AuthState({this.token, this.user, this.isLoading = false});

  AuthState copyWith({String? token, User? user, bool? isLoading}) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      try {
        final decodedToken = JwtDecoder.decode(token);
        final user = User(
          id: decodedToken['sub'],
          // Ensure your JWT includes 'email' and 'role' claims
          email: decodedToken['email'] ?? 'no-email@treqsy.com', 
          role: decodedToken['role'],
        );
        print('AuthNotifier: Loaded user from token: ' + user.email);
        state = state.copyWith(token: token, user: user, isLoading: false);
      } catch (e) {
        // If token is invalid or expired
        await prefs.remove('auth_token');
        state = AuthState(isLoading: false);
      }
    } else {
       state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        final decodedToken = JwtDecoder.decode(token);
        final user = User(
          id: decodedToken['sub'],
          role: data['role'], // Use role from login response
          email: decodedToken['email'] ?? email, 
        );
        print('AuthNotifier: Login successful, user: ' + user.email + ', role: ' + user.role);
        state = state.copyWith(token: token, user: user, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false);
      print('AuthNotifier: Login failed, status: ' + response.statusCode.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('AuthNotifier: Login exception: ' + e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 201;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('AuthNotifier: User logged out');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
}); 