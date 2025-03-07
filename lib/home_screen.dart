// ignore_for_file: use_build_context_synchronously

import 'package:attendance/attendance.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:attendance/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  Map<String, dynamic>? user;

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IAU'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: handleLogout,
          ),
        ],
      ),
      body: Center(
        child: user != null
            ? QRScannerScreen()
            : CircularProgressIndicator(),
      ),
    );
  }
}
