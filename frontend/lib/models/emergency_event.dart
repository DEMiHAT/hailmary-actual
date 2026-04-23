class EmergencyEvent {
  final String id;
  final String userId;
  final String location;
  final String description;
  final String timestamp;
  final String status;

  EmergencyEvent({
    required this.id,
    required this.userId,
    required this.location,
    required this.description,
    required this.timestamp,
    this.status = 'TRIGGERED',
  });

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) {
    return EmergencyEvent(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? 'TRIGGERED',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'location': location,
        'description': description,
        'timestamp': timestamp,
        'status': status,
      };
}
