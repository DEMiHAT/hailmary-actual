import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/emergency_event.dart';
import '../models/analysis_result.dart';
import '../models/vitals_result.dart';
import '../models/health_record.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  // Change this to your backend URL
  // Android emulator: http://10.0.2.2:8000
  // iOS simulator:    http://localhost:8000
  // Physical device:  http://<your-ip>:8000
  static const String _baseUrl = 'http://10.0.2.2:8000';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Logging interceptor for debug
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[API] $obj'),
    ));
  }

  // ─── Emergency ──────────────────────────────────────────────

  Future<EmergencyEvent> triggerEmergency({
    required String userId,
    required String location,
    required String description,
  }) async {
    final response = await _dio.post('/emergency', data: {
      'user_id': userId,
      'location': location,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return EmergencyEvent.fromJson(response.data);
  }

  // ─── ML Analysis ───────────────────────────────────────────

  Future<AnalysisResult> analyzeXray({
    required File imageFile,
    required int age,
    required String gender,
    required List<String> symptoms,
    required String duration,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'xray_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
      'age': age,
      'gender': gender,
      'symptoms': symptoms.join(','),
      'duration': duration,
    });

    final response = await _dio.post('/ml/analyze', data: formData);
    return AnalysisResult.fromJson(response.data);
  }

  // ─── Vitals ─────────────────────────────────────────────────

  Future<VitalsResult> submitVitals({
    required List<double> redSignal,
    required List<double> blueSignal,
    required double duration,
    required String userId,
  }) async {
    final response = await _dio.post('/ml/vitals', data: {
      'red_signal': redSignal.take(100).toList(), // Send a summary
      'blue_signal': blueSignal.take(100).toList(),
      'duration': duration,
      'user_id': userId,
    });
    return VitalsResult.fromJson(response.data);
  }

  // ─── Records ────────────────────────────────────────────────

  Future<List<HealthRecord>> getRecords({String? userId}) async {
    final response = await _dio.get('/records', queryParameters: {
      if (userId != null) 'user_id': userId,
    });
    final List<dynamic> data = response.data;
    return data.map((e) => HealthRecord.fromJson(e)).toList();
  }

  Future<HealthRecord> saveRecord(HealthRecord record) async {
    final response = await _dio.post('/records', data: record.toJson());
    return HealthRecord.fromJson(response.data);
  }
}
