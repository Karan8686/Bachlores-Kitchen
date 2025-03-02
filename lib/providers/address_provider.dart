import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressProvider with ChangeNotifier {
  static const String _addressKey = 'saved_addresses';
  static const String _selectedAddressKey = 'selected_address';
  
  List<Map<String, dynamic>> _savedAddresses = [];
  Map<String, dynamic>? _selectedAddress;

  List<Map<String, dynamic>> get savedAddresses => _savedAddresses;
  Map<String, dynamic>? get selectedAddress => _selectedAddress;

  AddressProvider() {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressKey);
    final selectedAddressJson = prefs.getString(_selectedAddressKey);

    if (addressesJson != null) {
      final List<dynamic> decoded = json.decode(addressesJson);
      _savedAddresses = decoded.cast<Map<String, dynamic>>();
    }

    if (selectedAddressJson != null) {
      _selectedAddress = json.decode(selectedAddressJson);
    }

    notifyListeners();
  }

  Future<void> saveAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Add to saved addresses if not exists
    if (!_savedAddresses.any((saved) => 
        saved['address'] == address['address'] && 
        saved['type'] == address['type'])) {
      _savedAddresses.add(address);
      await prefs.setString(_addressKey, json.encode(_savedAddresses));
    }

    // Set as selected address
    _selectedAddress = address;
    await prefs.setString(_selectedAddressKey, json.encode(address));
    
    notifyListeners();
  }

  Future<void> selectAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    _selectedAddress = address;
    await prefs.setString(_selectedAddressKey, json.encode(address));
    notifyListeners();
  }

  Future<void> removeAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    _savedAddresses.removeWhere((saved) => 
        saved['address'] == address['address'] && 
        saved['type'] == address['type']);
    
    if (_selectedAddress != null &&
        _selectedAddress!['address'] == address['address'] &&
        _selectedAddress!['type'] == address['type']) {
      _selectedAddress = _savedAddresses.isNotEmpty ? _savedAddresses.first : null;
      await prefs.setString(_selectedAddressKey, 
          _selectedAddress != null ? json.encode(_selectedAddress) : '');
    }

    await prefs.setString(_addressKey, json.encode(_savedAddresses));
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getSelectedAddress() async {
    if (_selectedAddress == null) {
      await _loadAddresses();
    }
    return _selectedAddress;
  }
}
