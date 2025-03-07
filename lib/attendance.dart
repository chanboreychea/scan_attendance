import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  String qrCodeResult = "";
  String message = "";
  String locationMessage = '';
  bool isInRadius =
      false; // Flag to indicate if the device is within 20 meters of the location

  String? token;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkLocation();
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

  // Function to get current location and check if within 20 meters
  Future<void> _checkLocation() async {
    // Request permission for location
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = 'Location permission denied';
      });
      return;
    }

    // Get the current position of the device
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Calculate the distance between current location and target location
    double distanceInMeters = Geolocator.distanceBetween(position.latitude,
        position.longitude, 11.632821786524302, 104.88333642210969);

    // Check if the distance is within 20 meters
    setState(() {
      isInRadius = distanceInMeters <= 20;
      // locationMessage =
      //     "Latitude: ${position.latitude}, Longitude: ${position.longitude}";

      if (isInRadius) {
        locationMessage += "\nYou're within 20 meters of the set location.";
      } else {
        locationMessage +=
            "\nYou're more than 20 meters away from the set location.";
      }
    });
  }

  // Function to send the QR scan data to the Laravel API
  void sendScanData(String qrCode) async {
    // final url = Uri.parse('https://google.com');
    final url = Uri.parse(qrCode);
    final DateTime now = DateTime.now();

    // Format date (e.g., 2025-03-07)
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String formattedDate = dateFormat.format(now);

    // Format timestamp (e.g., 14:44:00)
    final DateFormat timeFormat = DateFormat("HH:mm:ss");
    String formattedTimestamp = timeFormat.format(now);

    // Send POST request to the Laravel API
    final response = await http.post(
      url,
      body: json.encode({
        'uid': user!['id'],
        'date': formattedDate,
        'timestamp': formattedTimestamp,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Pass token here
      },
    );

    final responseData = jsonDecode(response.body);
    // Check response status
    if (response.statusCode == 200) {
      setState(() {
        message = responseData['message'];
      });
    } else {
      if (responseData.containsKey('message')) {
        setState(() {
          message = responseData['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan me...'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location message
          Text(locationMessage),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, User ID: ${user!['id']}'),
              Text('Username: ${user!['lastNameKh']} ${user!['firstNameKh']}'),
              Text('Token: ${token != null ? "okay" : "No Token"}'),
              Text('Datetime: ${DateTime.now().toIso8601String()}'),
            ],
          ),

          // Check if the user is within the radius
          if (isInRadius)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isScanning = !isScanning;
                });
              },
              child: Text(isScanning ? "Stop Scanning" : "Start Scanning"),
            ),

          // Show the camera when scanning is active
          if (isScanning)
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: (BarcodeCapture barcodeCapture) {
                  final barcode = barcodeCapture.barcodes.first;
                  final String code = barcode.rawValue ?? 'Unknown';
                  setState(() {
                    qrCodeResult = code;
                  });

                  // Send the scanned data to the Laravel API
                  sendScanData(code);

                  // Stop the scanner after detecting the QR code (optional)
                  setState(() {
                    isScanning = false;
                  });
                },
              ),
            )
          else
            Center(
              child: Text(
                // qrCodeResult.isEmpty
                //     ? 'Press the button to start scanning'
                //     : 'Scanned QR Code: $qrCodeResult',
                message.isEmpty
                    ? 'Press the button to start scanning'
                    : 'Message: $message',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
