// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:attendance/attendance_screen.dart';
import 'package:attendance/login_screen.dart';
import 'package:attendance/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  String? token;
  Map<String, dynamic>? user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');

    setState(() {
      token = storedToken;
      user = storedUser != null ? jsonDecode(storedUser) : null;
    });
  }

  void handleLogout() async {
    setState(() => isLoading = true);

    try {
      var response = await apiService.logout(token!);

      if (response != null) {
        setState(() => isLoading = false);

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: user != null
            ? AttendanceScreen(
                userIds: user!['id'].toString(),
                tokens: token!,
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
