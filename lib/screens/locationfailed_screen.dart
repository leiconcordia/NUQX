import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import 'signup_screen.dart';

class LocationScreenFailed extends StatefulWidget {
  const LocationScreenFailed({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreenFailed> {
  bool isWithinRange = false;

  void _simulateLocationCheck() {
    setState(() {
      isWithinRange = true; // Simulate a successful check
    });
    _showServiceAreaDialog();
  }

  void _showServiceAreaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Service Area Confirmation"),
          content: const Text(
            "You are within the service area. You can now join the queue.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Map Proximity"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Allow your location',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Icon(Icons.location_on, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      'You must be within 100m of the office to join the queue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // ✅ Larger, rounder button styled like Sign Up
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _simulateLocationCheck,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C), // NU Blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Pill shape
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Allow Location Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!isWithinRange)
                      _buildServiceAreaMessage(
                        context,
                        "Out of service area. You must be within 100m of the office to join the queue.",
                      ),
                  ],
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreaMessage(BuildContext context, String message) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 120,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Exit App"),
          ),
        ),
      ],
    );
  }
}
