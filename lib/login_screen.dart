import 'dart:convert';

import 'package:attendance/api_service.dart';
import 'package:attendance/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    Map<String, dynamic>? response = (await apiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    )) as Map<String, dynamic>?;

    setState(() => isLoading = false);

    if (response != null &&
        response.containsKey('token') &&
        response.containsKey('user')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']); // Store token
      await prefs.setString(
          'user', jsonEncode(response['user'])); // Store user object

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleLogin,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
