import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';

class GeoFencingAndroid extends GeoFencingPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('geo_fencing_android/method');
  static const EventChannel _eventChannel =
      EventChannel('geo_fencing_android/event');

  static void registerWith() {
    debugPrint('Dart: Registering Android platform implementation');
    GeoFencingPlatform.instance = GeoFencingAndroid();
  }

  Stream<GeoFenceEvent>? _eventStream;

  @override
  Future<void> initialize() async {
    debugPrint('Dart: Calling initialize on Android plugin');
    try {
      await _methodChannel.invokeMethod('initialize');
      debugPrint('Dart: Android initialize result: success');
    } catch (e) {
      debugPrint('Dart: Android initialize error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> registerGeoFences(List<GeoFenceRegion> regions) async {
    debugPrint(
        'Dart: Calling registerGeoFences with ${regions.length} regions');
    final regionsList = regions.map((r) => r.toJson()).toList();
    debugPrint('Dart: Regions data: $regionsList');

    try {
      final result = await _methodChannel
          .invokeMethod('registerGeoFences', {'regions': regionsList});
      debugPrint('Dart: registerGeoFences result: $result');
      return result ?? true;
    } catch (e) {
      debugPrint('Dart: registerGeoFences error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> removeGeoFence(String id) async {
    debugPrint('Dart: Calling removeGeoFence with id: $id');
    try {
      final result =
          await _methodChannel.invokeMethod('removeGeoFence', {'id': id});
      debugPrint('Dart: removeGeoFence result: $result');
      return result ?? true;
    } catch (e) {
      debugPrint('Dart: removeGeoFence error: $e');
      rethrow;
    }
  }

  @override
  Stream<GeoFenceEvent> onEvent() {
    debugPrint('Dart: Setting up Android event stream');
    _eventStream ??= _eventChannel.receiveBroadcastStream().map((event) {
      debugPrint('Dart: Raw event received from Android: $event');
      final Map<String, dynamic> map = Map<String, dynamic>.from(event);
      debugPrint('Dart: Parsed event map: $map');

      if (map.containsKey('error')) {
        debugPrint('Dart: Event contains error: ${map['error']}');
        throw Exception(map['error']);
      }

      debugPrint('Dart: Creating GeoFenceEvent from Android data');
      final geoFenceEvent = GeoFenceEvent(
        id: map['id'],
        transitionType: map['transition'] == 'ENTER'
            ? TransitionType.enter
            : TransitionType.exit,
        latitude: map['latitude'] ?? 0.0,
        longitude: map['longitude'] ?? 0.0,
        timestamp: DateTime.now(),
      );
      debugPrint('Dart: GeoFenceEvent created: $geoFenceEvent');
      return geoFenceEvent;
    });
    debugPrint('Dart: Android event stream setup complete');
    return _eventStream!;
  }
}
