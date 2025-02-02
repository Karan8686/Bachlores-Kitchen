class DeliveryAddress {
  final String id;
  final String address;
  final String type; // home, work, other
  final double latitude;
  final double longitude;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });
}
