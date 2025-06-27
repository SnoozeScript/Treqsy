class User {
  final String? id;
  final String email;
  final String role;
  final bool? isActive;
  final bool? isVip;
  final int coins;
  // Add other fields like kyc_info, bank_info later if needed

  User({
    this.id,
    required this.email,
    required this.role,
    this.isActive,
    this.isVip,
    this.coins = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      role: json['role'] ?? 'user',
      isActive: json['is_active'],
      isVip: json['is_vip'] ?? false,
      coins: json['coins'] ?? 0,
    );
  }

  bool get isHost => role == 'host';
  bool get isAdmin => role == 'admin';
  bool get isMasterAdmin => role == 'master_admin';
} 