import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:http/http.dart' as http;

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  final LatLng _restaurantLocation = const LatLng(19.1933991, 72.8672557);
  LatLng? _deliveryLocation;
  String _distance = '';
  String _estimatedTime = '';

  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];
  bool _isDetailsExpanded = false;
  bool _isLoading = true;

  final double _collapsedBottomPadding = 90.0;
  final double _expandedBottomPadding = 220.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _requestLocationService();
        if (!serviceEnabled) {
          return;
        }
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  Future<bool> _requestLocationService() async {
    if (!mounted) return false;
    
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Required'),
          content: const Text('Please enable location services to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Settings'),
              onPressed: () async {
                await geo.Geolocator.openLocationSettings();
                if (mounted) Navigator.of(context).pop();
                result = await geo.Geolocator.isLocationServiceEnabled();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                result = false;
              },
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<void> _getCurrentLocation() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high
      );

      if (!mounted) return;

      setState(() {
        _deliveryLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _initializeMap();
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (!mounted) return;
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
        markerId: const MarkerId('restaurant'),
        position: _restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      if (_deliveryLocation != null)
        Marker(
          markerId: const MarkerId('delivery'),
          position: _deliveryLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
    ]);
  }

  void _setPolylineCoordinates() async {
    _polylineCoordinates.clear();
    if (_deliveryLocation != null) {
      List<LatLng> route = await _getRouteWithDrivingMode(_restaurantLocation, _deliveryLocation!);
      _polylineCoordinates.addAll(route);
      debugPrint('Polyline coordinates: $_polylineCoordinates');
      setState(() {});
    }
  }

  Future<List<LatLng>> _getRouteWithDrivingMode(LatLng start, LatLng end) async {
    final String apiKey = 'AIzaSyBN6PuIf3TsMy0RS2mSlp_GQF10j1lQ4IU';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> route = [];
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        route.addAll(_decodePolyline(points));
      }
      return route;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double radiusOfEarth = 6371;
    double latDistance = _degreesToRadians(end.latitude - start.latitude);
    double lonDistance = _degreesToRadians(end.longitude - start.longitude);

    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(lonDistance / 2) * sin(lonDistance / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _calculateDistanceAndTime() {
    if (_deliveryLocation != null) {
      double distance = _calculateDistance(_restaurantLocation, _deliveryLocation!);
      const double averageSpeedKmPerHour = 40.0;
      double estimatedTimeInHours = distance / averageSpeedKmPerHour;
      double estimatedTimeInMinutes = estimatedTimeInHours * 60;

      setState(() {
        _distance = '${(distance * 1000).toStringAsFixed(0)} m';
        _estimatedTime = '${estimatedTimeInMinutes.toStringAsFixed(0)} mins';

      });
    }
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
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
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
                polylineId: const PolylineId('route'),
                points: _polylineCoordinates,
                color: theme.colorScheme.primary,
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
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.surface),
                onPressed: _getCurrentLocation,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.surface),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: 16,
            bottom: _isDetailsExpanded ? _expandedBottomPadding : _collapsedBottomPadding,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(Icons.my_location, color: theme.colorScheme.surface),
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
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isDetailsExpanded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'On The Way',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.surface,
                        fontFamily: "poppins"
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arrives between 11:23 PM-12:01 AM',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.store, color: theme.colorScheme.surface),
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.onPrimary,
                            indent: 8,
                            endIndent: 8,
                          ),
                        ),
                        Icon(Icons.delivery_dining, color: theme.colorScheme.surface),
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.secondary,
                            indent: 8,
                            endIndent: 8,
                          ),
                        ),
                        Icon(Icons.home, color: theme.colorScheme.surface),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Karan is preparing your order.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.surface,
                        fontFamily: "poppins"
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arrives in $_estimatedTime',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontFamily: "poppins"
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onPrimary,
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
