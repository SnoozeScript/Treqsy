import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treqsy_platform/domain/models/stream_session.dart';
import 'package:treqsy_platform/models/user_model.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final apiServiceProvider = Provider((ref) => ApiService(ref));

class ApiService {
  final Ref _ref;
  ApiService(this._ref);

  static const String baseUrl = "http://192.168.1.9:8000";

  Map<String, String> get _headers {
    final token = _ref.read(authProvider).token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Admin/Master Admin ---
  Future<List<dynamic>> listUsers() async {
    final url = Uri.parse('$baseUrl/admin/users');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    final url = Uri.parse('$baseUrl/admin/users/$userId/role');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(newRole),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to change user role');
    }
  }

  Future<void> activateUser(String userId, bool active) async {
    final url = Uri.parse('$baseUrl/admin/users/$userId/activate');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(active),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user status');
    }
  }

  Future<void> toggleVipStatus(String userId, bool isVip) async {
    final url = Uri.parse('$baseUrl/admin/users/$userId/vip');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(isVip),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update VIP status');
    }
  }

  Future<String> getAppName() async {
    final url = Uri.parse('$baseUrl/admin/settings/app_name');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['app_name'] ?? 'Treqsy';
    } else {
      throw Exception('Failed to fetch app name');
    }
  }

  Future<void> setAppName(String name) async {
    final url = Uri.parse('$baseUrl/admin/settings/app_name');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(name),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update app name');
    }
  }

  Future<Map<String, dynamic>> getWalletAnalytics() async {
    final url = Uri.parse('$baseUrl/admin/wallet/analytics');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch wallet analytics');
    }
  }

  Future<String> getRazorpayKey() async {
    final url = Uri.parse('$baseUrl/admin/settings/razorpay_key');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['razorpay_key'] ?? '';
    } else {
      throw Exception('Failed to fetch Razorpay key');
    }
  }

  Future<void> setRazorpayKey(String key) async {
    final url = Uri.parse('$baseUrl/admin/settings/razorpay_key');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(key),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update Razorpay key');
    }
  }

  // --- Existing methods (unchanged) ---
  Future<User> fetchUserProfile() async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
       _ref.read(authProvider.notifier).state = _ref.read(authProvider).copyWith(user: user);
      return user;
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  Future<StreamSession> startStream(String title) async {
    final url = Uri.parse('$baseUrl/streams/start?title=$title');
    final response = await http.post(url, headers: _headers);
    if (response.statusCode == 200) {
      return StreamSession.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start stream: ${response.body}');
    }
  }

  Future<List<StreamSession>> getActiveStreams() async {
    final url = Uri.parse('$baseUrl/streams/active');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => StreamSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch streams');
    }
  }

  Future<int> getCoinBalance(String userId) async {
    final url = Uri.parse('$baseUrl/admin/coins/balance');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['coins'] ?? 0;
    } else {
      throw Exception('Failed to fetch coin balance');
    }
  }

  Future<void> purchaseCoins(String userId, int amount) async {
    final url = Uri.parse('$baseUrl/admin/coins/purchase');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({"user_id": userId, "amount": amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to purchase coins');
    }
  }

  Future<void> giftCoins(String fromUser, String toUser, int amount) async {
    final url = Uri.parse('$baseUrl/admin/coins/gift');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({"from_user": fromUser, "to_user": toUser, "amount": amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to gift coins');
    }
  }

  Future<void> requestPayout(String userId, int amount) async {
    final url = Uri.parse('$baseUrl/admin/coins/payout/request');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({"user_id": userId, "amount": amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to request payout');
    }
  }

  Future<void> approvePayout(String requestId) async {
    final url = Uri.parse('$baseUrl/admin/coins/payout/approve');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({"request_id": requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to approve payout');
    }
  }

  Future<List<dynamic>> getCoinTransactions(String userId) async {
    final url = Uri.parse('$baseUrl/admin/coins/transactions/$userId');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<Map<String, dynamic>> getCoinAnalytics() async {
    final url = Uri.parse('$baseUrl/admin/coins/analytics');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch coin analytics');
    }
  }

  Future<Map<String, dynamic>> getCoinSettings() async {
    final url = Uri.parse('$baseUrl/admin/coins/settings');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch coin settings');
    }
  }

  Future<void> setCoinSettings(Map<String, dynamic> settings) async {
    final url = Uri.parse('$baseUrl/admin/coins/settings');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(settings),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update coin settings');
    }
  }

  Future<List<dynamic>> getPendingPayoutRequests() async {
    final url = Uri.parse('$baseUrl/admin/coins/payout/requests');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch payout requests');
    }
  }

  Future<List<User>> getAllHosts() async {
    final url = Uri.parse('$baseUrl/admin/users');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return users
          .where((u) => u['role'] == 'host')
          .map((u) => User.fromJson(u))
          .toList();
    } else {
      throw Exception('Failed to fetch hosts');
    }
  }
} 