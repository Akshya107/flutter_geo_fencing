class GeoFenceRegion {
  final String id;
  final double latitude;
  final double longitude;
  final double radius;

  const GeoFenceRegion({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };
}
