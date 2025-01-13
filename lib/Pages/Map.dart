import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late GoogleMapController _mapController;
  final LatLng _restaurantLocation = LatLng(37.7749, -122.4194); // Example: San Francisco
  final LatLng _deliveryLocation = LatLng(37.7849, -122.4094); // Example: Cupertino
  final LatLng _driverLocation = LatLng(37.7799, -122.4144); // Example: Intermediate location
  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];
  String _distance = 'Calculating...';
  String _estimatedTime = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _setMarkers();
    _setPolylineCoordinates();
    _calculateDistanceAndTime();
  }

  void _setMarkers() {
    _markers.addAll([
      Marker(
        markerId: MarkerId('restaurant'),
        position: _restaurantLocation,
        infoWindow: InfoWindow(title: 'Restaurant'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: MarkerId('delivery'),
        position: _deliveryLocation,
        infoWindow: InfoWindow(title: 'Delivery Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: MarkerId('driver'),
        position: _driverLocation,
        infoWindow: InfoWindow(title: 'Driver'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    ]);
  }

  void _setPolylineCoordinates() {
    _polylineCoordinates.addAll([
      _restaurantLocation,
      _driverLocation,
      _deliveryLocation,
    ]);
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
    double distance = _calculateDistance(_driverLocation, _deliveryLocation);
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
  }

  void _centerOnDriver() {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_driverLocation, 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _driverLocation,
              zoom: 13.0,
            ),
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                points: _polylineCoordinates,
                color: Colors.blueAccent,
                width: 5,
              ),
            },
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/driver_avatar.png'), // Replace with your asset
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mike Rojnidoost',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$_distance - $_estimatedTime',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Colors.purple,
                    ),
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerOnDriver,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
