import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late GoogleMapController _mapController;
  final LatLng _restaurantLocation = LatLng(19.1933991,72.8672557);
  LatLng? _deliveryLocation;
  double? locationn;
  String _distance='';
  String _estimatedTime='';

  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];
  bool _isDetailsExpanded = false;
  bool _isLoading = true;

  // Constants for positioning
  final double _collapsedBottomPadding = 90.0;
  final double _expandedBottomPadding = 220.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text('We need your location to deliver your order. Please enable location services to continue.'),
            actions: [
              TextButton(
                child: Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable the services')),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
         _deliveryLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _initializeMap();
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeMap() {
    if (_deliveryLocation != null) {
      _setMarkers();
      _setPolylineCoordinates();
    }
  }

  void _setMarkers() {
    _markers.clear();
    _markers.addAll([
      Marker(
        markerId: MarkerId('restaurant'),
        position: _restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      if (_deliveryLocation != null)
        Marker(
          markerId: MarkerId('delivery'),
          position: _deliveryLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
    ]);
  }

  void _setPolylineCoordinates() {
    _polylineCoordinates.clear();
    if (_deliveryLocation != null) {
      _polylineCoordinates.addAll([
        _restaurantLocation,
        _deliveryLocation!,
      ]);
    }
  }
  /// Haversine Formula to Calculate Distance
  double _calculateDistance(LatLng start, LatLng end) {
    const double radiusOfEarth = 6371; // Radius of Earth in kilometers
    double latDistance = _degreesToRadians(end.latitude - start.latitude);
    double lonDistance = _degreesToRadians(end.longitude - start.longitude);

    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(lonDistance / 2) * sin(lonDistance / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  void _calculateDistanceAndTime() {
    double distance = _calculateDistance(_restaurantLocation, _restaurantLocation);
    const double averageSpeedKmPerHour = 40.0; // Assume average speed in km/h
    double estimatedTimeInHours = distance / averageSpeedKmPerHour;
    double estimatedTimeInMinutes = estimatedTimeInHours * 60;

    setState(() {
      _distance = '${(distance * 1000).toStringAsFixed(0)} m'; // Distance in meters
      _estimatedTime = '${estimatedTimeInMinutes.toStringAsFixed(0)} mins';
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle('''
      [
        {
          "featureType": "all",
          "elementType": "geometry",
          "stylers": [{"color": "#f5f5f5"}]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [{"color": "#ffffff"}]
        }
      ]
    ''');
  }

  Future<void> _centerOnLocation() async {
    if (_deliveryLocation != null) {
      await _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_deliveryLocation!, 16.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepOrangeAccent,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _deliveryLocation ?? _restaurantLocation,
              zoom: 15.0,
            ),
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                points: _polylineCoordinates,
                color: Colors.deepOrangeAccent,
                width: 4,
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.refresh, color: Colors.black),
                onPressed: _getCurrentLocation,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {

                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: 16,
            bottom: _isDetailsExpanded ? _expandedBottomPadding : _collapsedBottomPadding,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.my_location, color: Colors.black),
                onPressed: _centerOnLocation,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDetailsExpanded = !_isDetailsExpanded;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isDetailsExpanded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'On The Way',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Arrives between 11:23 PM-12:01 AM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.white),
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            indent: 8,
                            endIndent: 8,
                          ),
                        ),
                        Icon(Icons.delivery_dining, color: Colors.white),
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            indent: 8,
                            endIndent: 8,
                          ),
                        ),
                        Icon(Icons.home, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Karan is preparing your order.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arrives in ${_distance.toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}