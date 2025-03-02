import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({
    Key? key,
    this.initialLocation,
  }) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  bool _showSearchResults = false;

  static const String _apiKey = 'AIzaSyBN6PuIf3TsMy0RS2mSlp_GQF10j1lQ4IU';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$query'
      '&key=$_apiKey'
      '&components=country:in'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _searchResults = data['predictions'];
          _showSearchResults = true;
        });
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);
        
        setState(() {
          _selectedLocation = latLng;
          _showSearchResults = false;
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 17),
        );

        await _getAddressFromLatLng(latLng);
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      setState(() => _isLoading = true);
      
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty)
         .join(', ');

        setState(() => _selectedAddress = address);
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(20.5937, 78.9629),
              zoom: _selectedLocation != null ? 17 : 5,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _selectedLocation != null ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() => _selectedLocation = newPosition);
                  _getAddressFromLatLng(newPosition);
                },
              ),
            } : {},
            onTap: (location) {
              setState(() => _selectedLocation = location);
              _getAddressFromLatLng(location);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchPlaces,
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _showSearchResults = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showSearchResults)
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            title: Text(result['description']),
                            onTap: () {
                              _getPlaceDetails(result['place_id']);
                              _searchController.text = result['description'];
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedLocation != null && !_showSearchResults)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Location',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 8.h),
                        Text(_selectedAddress),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'address': _selectedAddress,
                        'location': _selectedLocation,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20.w),
                        SizedBox(width: 8.w),
                        const Text('Confirm Location'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 