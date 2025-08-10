import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';

class GeoFencingIos extends GeoFencingPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('geo_fencing_ios/method');
  static const EventChannel _eventChannel =
      EventChannel('geo_fencing_ios/event');

  static void registerWith() {
    GeoFencingPlatform.instance = GeoFencingIos();
  }

  Stream<GeoFenceEvent>? _eventStream;

  @override
  Future<void> initialize() async {
    debugPrint('Dart: Calling initialize on iOS plugin');
    try {
      await _methodChannel.invokeMethod('initialize');
    } catch (e) {
      debugPrint('Dart: Initialize error: $e');
      rethrow;
    }
  }

  Future<int> checkAuthorizationStatus() async {
    debugPrint('Dart: Checking iOS authorization status');
    try {
      final result = await _methodChannel.invokeMethod('checkAuthorizationStatus');
      debugPrint('Dart: Authorization status: $result');

      final statusText = _getAuthorizationStatusText(result);
      debugPrint('Dart: Authorization meaning: $statusText'); // ← Add this

      return result as int;
    } catch (e) {
      debugPrint('Dart: Authorization status error: $e');
      rethrow;
    }
  }

  String _getAuthorizationStatusText(int status) {
    switch (status) {
      case 0: return 'Not Determined';
      case 1: return 'Restricted';
      case 2: return 'Denied';
      case 3: return 'Authorized When In Use';
      case 4: return 'Authorized Always';
      default: return 'Unknown ($status)';
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
      return result;
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
      return result;
    } catch (e) {
      debugPrint('Dart: removeGeoFence error: $e');
      rethrow;
    }
  }

  @override
  Stream<GeoFenceEvent> onEvent() {
    debugPrint('Dart: Setting up event stream');
    _eventStream ??= _eventChannel.receiveBroadcastStream().map((event) {
      debugPrint('Dart: Raw event received: $event');
      final Map<String, dynamic> map = Map<String, dynamic>.from(event);
      debugPrint('Dart: Parsed event map: $map');
      if (map.containsKey('error')) {
        debugPrint('Dart: Event contains error: ${map['error']}');
        throw Exception(map['error']);
      }
      debugPrint('Dart: Creating GeoFenceEvent from map');
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
    debugPrint('Dart: Event stream setup complete');
    return _eventStream!;
  }
}
