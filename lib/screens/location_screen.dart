import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_header.dart';
import '../widgets/main_scaffold.dart';
import '../widgets/custom_footer.dart';
import 'home_screen.dart';

class LocationScreen extends StatefulWidget {
  final String userName;

  const LocationScreen({super.key, required this.userName});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkAndHandleLocation();
  }

  Future<void> _checkAndHandleLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse)) {
      setState(() {
        locationEnabled = true;
      });

      // Show loading and get location
      await _getUserLocation();
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Getting your location...",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse)) {
      setState(() {
        locationEnabled = true;
      });
    }
  }

  Future<void> _getUserLocation() async {
    showLoadingDialog(context);
    try {
      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

      // Dismiss the loading dialog
      Navigator.of(context).pop();

      //11.1353796, Lng 124.551826 akoa loc
      // 11.135376380746077, 124.55192934141948 balay
      //11.13495786420349, 124.55304600729069  test sa layu

      //NUP
      //14.604354869275541, 120.99453311592958

      // Office coordinates
      const double officeLat = 11.1353796;
      const double officeLng = 124.551826;

      // Calculate distance
      double distanceInMeters = Geolocator.distanceBetween(
        officeLat,
        officeLng,
        position.latitude,
        position.longitude,
      );

      // Output
      print('📍 User location: Lat ${position.latitude}, Lng ${position.longitude}');
      print('📏 Distance from office: ${distanceInMeters.toStringAsFixed(2)} meters');

      if (distanceInMeters <= 100) {
        print('✅ You are within range (100 meters)');
        _showServiceAreaDialog();
      } else {
        print('❌ You are outside the allowed range');
        _showOutOfRangeDialog(distanceInMeters); // <-- make sure this is called
      }

    } catch (e) {
      Navigator.of(context).pop(); // Ensure dialog is dismissed on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }


  void _showServiceAreaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Service Area Confirmation"),
          content: const Text(
              "You are within the service area. You can now join the queue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScaffold(userName: widget.userName),
                  ),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  void _showOutOfRangeDialog(double distanceInMeters) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Out of Range"),
          content: Text(
              "You are not within the service area.\n"
                  "Distance from office: ${distanceInMeters.toStringAsFixed(2)} meters.\n"
                  "Please get closer to the office."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
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
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: locationEnabled ? null : _getUserLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          locationEnabled
                              ? 'Location Already Enabled'
                              : 'Allow Location Access',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: _getUserLocation,
                        icon: const Icon(Icons.refresh, color: Color(0xFF2D3A8C)),
                        label: const Text(
                          'Retry Location Check',
                          style: TextStyle(
                            color: Color(0xFF2D3A8C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2D3A8C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
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

}