import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/secrets.dart';
import 'package:food_ninja/src/data/services/geoservices.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class SetLocationMapScreen extends StatefulWidget {
  const SetLocationMapScreen({super.key});

  @override
  State<SetLocationMapScreen> createState() => _SetLocationMapScreenState();
}

class _SetLocationMapScreenState extends State<SetLocationMapScreen> {
  Position? _currentPosition;
  LatLng? selectedLocation;
  String? _placeName;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await Geoservices().getCurrentLocation();
      if (mounted) {
        final location = LatLng(position.latitude, position.longitude);
        String place = await Geoservices().reverseGeocoding(
          location.latitude,
          location.longitude,
        );

        setState(() {
          _currentPosition = position;
          selectedLocation = location;
          _placeName = place;
        });
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorColor,
            content: Text('Failed to get location: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
        // Set default location as fallback
        setState(() {
          _currentPosition = Position(
            latitude: 28.6139, // Example: New Delhi
            longitude: 77.2090,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
          selectedLocation = const LatLng(28.6139, 77.2090);
          _placeName = 'Location unavailable - Using default';
        });
      }
    }
  }

  void _selectLocation(LatLng position) async {
    setState(() {
      selectedLocation = position;
      _placeName = 'Fetching address...'; // Show loading state
    });

    try {
      String place = await Geoservices().reverseGeocoding(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _placeName = place;
        });
      }
    } catch (e) {
      debugPrint('Error getting place name: $e');
      if (mounted) {
        setState(() {
          _placeName = 'Address unavailable';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null || selectedLocation == null) {
      return const LoadingIndicator();
    }
    return _buildMap();
  }

  Widget _buildMap() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 18.0,
              maxZoom: 18.0,
              initialCenter: selectedLocation!,
              onTap: (tapPosition, latLng) => _selectLocation(latLng),
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180.0),
                  const LatLng(90.0, 180.0),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 216,
                    height: 216,
                    point: selectedLocation!,
                    child: SvgPicture.asset(
                      "assets/svg/map-pin-radar.svg",
                      width: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Place name display
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _placeName ?? "Fetching place name...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Buttons to re-center
          Positioned(
            bottom: 80,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "live_location",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDarkColor,
                  onPressed: () {
                    if (_currentPosition != null) {
                      final loc = LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      );
                      _mapController.move(loc, 18);
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "pointer_location",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDarkColor,
                  onPressed: () {
                    if (selectedLocation != null) {
                      _mapController.move(selectedLocation!, 18);
                    }
                  },
                  child: const Icon(Icons.location_pin),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDarkColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (selectedLocation != null) {
            String placeName = await Geoservices().reverseGeocoding(
              selectedLocation!.latitude,
              selectedLocation!.longitude,
            );

            Hive.box('myBox').put('location', placeName);

            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
