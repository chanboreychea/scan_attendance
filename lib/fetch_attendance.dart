import 'dart:convert';

import 'package:attendance/home_screen.dart';
import 'package:flutter/material.dart';
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
  Future<List<Attendance>> fetchAttendance(String userId, String token) async {
    final String apiUrl =
        'http://172.16.15.186:8000/api/v1/attendances/user/$userId';
    try {
      final response = await http.get(
        Uri.parse(apiUrl), // Append userId to the URL if needed
        headers: {'Authorization': 'Bearer $token'}, // Add token to headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['message'] == 'success' &&
            responseData['data'] is List) {
          List<dynamic> data = responseData['data'];
          return data.map((json) => Attendance.fromJson(json)).toList();
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }
}

class AttendanceScreen extends StatefulWidget {
  final String userIds;
  final String tokens;

  const AttendanceScreen({required this.userIds, required this.tokens});

  @override
  // ignore: library_private_types_in_public_api
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Attendance>> _attendanceFuture;

  String? token;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _attendanceFuture =
        AttendanceService().fetchAttendance(widget.userIds, widget.tokens);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 99, 189),
        title: Text(
          'Attendance',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Attendance>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No attendance records found.'));
          }

          List<Attendance> attendanceList = snapshot.data!;
          return ListView.builder(
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return Card(
                child: ListTile(
                  title: Text('Date: ${attendance.date}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Mission: ${attendance.mission != null ? "Leave" : "N/A"}'),
                      Text('Check-in: ${attendance.checkIn ?? "N/A"}'),
                      Text('Check-out: ${attendance.checkOut ?? "N/A"}'),
                    ],
                  ),
                  trailing:
                      Text(attendance.leave != null ? "Leave" : 'Present'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
