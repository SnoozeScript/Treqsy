class StreamSession {
  final String id;
  final String hostEmail;
  final String? title;
  final DateTime startTime;
  final bool isActive;

  StreamSession({
    required this.id,
    required this.hostEmail,
    this.title,
    required this.startTime,
    required this.isActive,
  });

  factory StreamSession.fromJson(Map<String, dynamic> json) {
    return StreamSession(
      id: json['_id'],
      hostEmail: json['host_email'],
      title: json['title'],
      startTime: DateTime.parse(json['start_time']),
      isActive: json['is_active'],
    );
  }
} 