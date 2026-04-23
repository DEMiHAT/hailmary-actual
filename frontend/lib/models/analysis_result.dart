class AnalysisResult {
  final String prediction;
  final double confidence;
  final String riskLevel;
  final String heatmapUrl;
  final String recommendation;

  AnalysisResult({
    required this.prediction,
    required this.confidence,
    required this.riskLevel,
    required this.heatmapUrl,
    required this.recommendation,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      prediction: json['prediction'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'LOW',
      heatmapUrl: json['heatmap_url'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'prediction': prediction,
        'confidence': confidence,
        'risk_level': riskLevel,
        'heatmap_url': heatmapUrl,
        'recommendation': recommendation,
      };

  String get predictionDisplay {
    switch (prediction) {
      case 'TB_DETECTED':
        return 'TB Detected';
      case 'PNEUMONIA_DETECTED':
        return 'Pneumonia Detected';
      case 'NORMAL':
        return 'Normal';
      default:
        return prediction.replaceAll('_', ' ');
    }
  }
}
