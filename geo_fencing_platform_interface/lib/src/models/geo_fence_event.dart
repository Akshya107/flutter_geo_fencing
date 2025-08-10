enum TransitionType { enter, exit }

class GeoFenceEvent {
  final String id;
  final TransitionType transitionType;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  GeoFenceEvent({
    required this.id,
    required this.transitionType,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}
