// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:attendance/services/auth.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    try {
      var response = await apiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response != null) {
        setState(() => isLoading = false);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        await prefs.setString('user', jsonEncode(response['user']));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login failed. Please check your credentials.')),
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
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(50), // Set height to allow image to be visible
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 9, 99, 189),
          title: Text(
            'blackJack.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300, // Set the width of the container
                  height: 200, // Set the height of the container
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('images/logo.png'), // Use your image here
                      // fit: BoxFit.cover, // Adjusts image size to fit AppBar
                    ),
                  ),
                ),
                SizedBox(height: 70),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    // labelText: 'Email',
                    labelStyle:
                        TextStyle(color: const Color.fromARGB(255, 1, 88, 159)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    // labelText: 'Password',
                    labelStyle:
                        TextStyle(color: const Color.fromARGB(255, 1, 88, 159)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Trigger validation when the button is pressed
                            if (_formKey.currentState!.validate()) {
                              handleLogin();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Please fix the errors')),
                              );
                            }
                          },
                          icon:
                              Icon(Icons.login, size: 24, color: Colors.white),
                          label: Text('Login'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 9, 99, 189),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
