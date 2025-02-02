import 'package:flutter/foundation.dart';
import '../models/delivery_address.dart';

class AddressProvider extends ChangeNotifier {
  DeliveryAddress? _selectedAddress;
  final List<DeliveryAddress> _addresses = [];

  DeliveryAddress? get selectedAddress => _selectedAddress;
  List<DeliveryAddress> get addresses => _addresses;

  void setSelectedAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress(DeliveryAddress address) {
    _addresses.add(address);
    if (_addresses.length == 1 || address.isDefault) {
      _selectedAddress = address;
    }
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((address) => address.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }
}
