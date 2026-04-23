class VitalsResult {
  final int heartRate;
  final int spo2Estimate;
  final double confidence;

  VitalsResult({
    required this.heartRate,
    required this.spo2Estimate,
    required this.confidence,
  });

  factory VitalsResult.fromJson(Map<String, dynamic> json) {
    return VitalsResult(
      heartRate: (json['heart_rate'] ?? 0).toInt(),
      spo2Estimate: (json['spo2_estimate'] ?? 0).toInt(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'heart_rate': heartRate,
        'spo2_estimate': spo2Estimate,
        'confidence': confidence,
      };

  String get heartRateStatus {
    if (heartRate < 60) return 'Low';
    if (heartRate > 100) return 'High';
    return 'Normal';
  }

  String get spo2Status {
    if (spo2Estimate < 90) return 'Critical';
    if (spo2Estimate < 95) return 'Low';
    return 'Normal';
  }
}
