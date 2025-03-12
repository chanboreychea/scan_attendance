import 'package:attendance/attendance.dart';
import 'package:attendance/services/attendance.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  final String userIds;
  final String tokens;

  const AttendanceScreen(
      {super.key, required this.userIds, required this.tokens});

  @override
  // ignore: library_private_types_in_public_api
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService attService = AttendanceService();
  late Future<List<Attendance>> _attendanceFuture;
  List<Attendance> _attendanceList = [];
  List<Attendance> _filteredAttendanceList = [];
  final TextEditingController _searchController = TextEditingController();

  String? token;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAndSetAttendance();
  }

  Future<List<Attendance>> fetchAndSetAttendance() async {
    try {
      List<Attendance> data =
          await attService.fetchAttendance(widget.userIds, widget.tokens);
      setState(() {
        _attendanceList = data;
        _filteredAttendanceList = data; // Initially, filtered list = full list
      });
      return data;
    } catch (e) {
      return [];
    }
  }

  void _filterAttendance(String query) {
    if (query.toLowerCase() == "leave") {
      query = 1 as String;
    } else if (query.toLowerCase() == "mission") {
      query = 1 as String;
    }
    setState(() {
      _filteredAttendanceList = _attendanceList.where((attendance) {
        return attendance.date.contains(query) ||
            (attendance.mission != null &&
                attendance.mission!.toLowerCase().contains("1")) ||
            (attendance.checkIn != null &&
                attendance.checkIn!.contains(query)) ||
            (attendance.checkOut != null &&
                attendance.checkOut!.contains(query)) ||
            (attendance.leave != null &&
                attendance.leave!.toLowerCase().contains("1"));
      }).toList();
    });
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
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAttendance,
              decoration: InputDecoration(
                labelText: "Search by Date, Mission, or Leave",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Attendance>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No attendance records found.'));
                }

                return ListView.builder(
                  itemCount: _filteredAttendanceList.length,
                  itemBuilder: (context, index) {
                    final attendance = _filteredAttendanceList[index];
                    return Card(
                      child: ListTile(
                        title: Text('Date: ${attendance.date}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in: ${attendance.checkIn ?? "N/A"}',
                              style: TextStyle(
                                color: attendance.checkIn != null &&
                                        DateTime.parse(
                                                "${attendance.date} ${attendance.checkIn!}")
                                            .isAfter(DateTime.parse(
                                                '${attendance.date} 09:00:00'))
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            Text('Check-out: ${attendance.checkOut ?? "N/A"}',
                                style: TextStyle(
                                  color: attendance.checkOut != null &&
                                              DateTime.parse(
                                                      "${attendance.date} ${attendance.checkOut!}")
                                                  .isBefore(DateTime.parse(
                                                      '${attendance.date} 16:00:00')) ||
                                          attendance.checkOut != null &&
                                              DateTime.parse(
                                                      "${attendance.date} ${attendance.checkOut!}")
                                                  .isAfter(DateTime.parse(
                                                      '${attendance.date} 17:30:00'))
                                      ? Colors.red
                                      : Colors.black,
                                )),
                            Text(
                              'Total: ${attendance.total ?? "N/A"}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        trailing: Text(
                          attendance.leave != null
                              ? "Leave"
                              : attendance.mission != null
                                  ? 'Mission'
                                  : 'Present',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: attendance.leave != null
                                  ? Colors.red
                                  : attendance.mission != null
                                      ? Colors.amber
                                      : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
