class HealthRecord {
  final String id;
  final String userId;
  final String type; // 'xray', 'vitals', 'emergency'
  final String date;
  final String resultSummary;
  final String riskLevel;
  final Map<String, dynamic> details;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.resultSummary,
    required this.riskLevel,
    required this.details,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      resultSummary: json['result_summary'] ?? '',
      riskLevel: json['risk_level'] ?? 'LOW',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'date': date,
        'result_summary': resultSummary,
        'risk_level': riskLevel,
        'details': details,
      };

  String get typeDisplay {
    switch (type) {
      case 'xray':
        return 'X-Ray Analysis';
      case 'vitals':
        return 'Vitals Check';
      case 'emergency':
        return 'Emergency';
      default:
        return type;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'xray':
        return '🩻';
      case 'vitals':
        return '❤️';
      case 'emergency':
        return '🚨';
      default:
        return '📋';
    }
  }
}
