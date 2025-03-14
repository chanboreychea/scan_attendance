import 'dart:convert';

import 'package:attendance/services/urls.dart';
import 'package:http/http.dart' as http;

class Attendance {
  final int id;
  final String userId;
  final String date;
  final String? leave;
  final String? checkIn;
  final String? lateIn;
  final String? checkOut;
  final String? lateOut;
  final String? total;
  final String? mission;
  final String? exitFirst;
  final String createdAt;
  final String updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.leave,
    this.checkIn,
    this.lateIn,
    this.checkOut,
    this.lateOut,
    this.total,
    this.mission,
    this.exitFirst,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      userId: json['userId']?.toString() ?? "N/A",
      date: json['date'] ?? "Unknown",
      leave: json['leave']?.toString(),
      checkIn: json['checkIn']?.toString(),
      lateIn: json['lateIn']?.toString(),
      checkOut: json['checkOut']?.toString(),
      lateOut: json['lateOut']?.toString(),
      total: json['total']?.toString(),
      mission: json['mission']?.toString(),
      exitFirst: json['exitFirst']?.toString(),
      createdAt: json['created_at'] ?? "Unknown",
      updatedAt: json['updated_at'] ?? "Unknown",
    );
  }
}

class AttendanceService {
  final String apiUrl = API_URL;

  Future<List<Attendance>> fetchAttendance(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl/v1/attendances/user/$userId'), // Append userId to the URL if needed
        headers: {'Authorization': 'Bearer $token'}, // Add token to headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // if (responseData['message'] == 'success' &&
        //     responseData['data'] is List) {
        List<dynamic> data = responseData['data'];
        return data.map((json) => Attendance.fromJson(json)).toList();
        // } else {
        //   throw Exception('Invalid data format');
        // }
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }
}
