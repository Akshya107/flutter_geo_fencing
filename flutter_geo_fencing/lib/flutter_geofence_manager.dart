library flutter_geofence_manager;

import 'dart:io';

import 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';
import 'package:geo_fencing_android/geo_fencing_android.dart';
import 'package:geo_fencing_ios/geo_fencing_ios.dart';

// Export the platform interface for direct access if needed
export 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';

/// A cross-platform Flutter plugin for geofencing functionality.
///
/// This plugin provides background location monitoring and geofence event handling
/// for both Android and iOS platforms.
class FlutterGeofenceManager {
  FlutterGeofenceManager._(); // private constructor

  static final instance = FlutterGeofenceManager._();
  static bool _registered = false;

  /// Register platform implementations.
  /// This method should be called before using any geofencing functionality.
  static void registerPlatforms() {
    if (_registered) return;

    if (Platform.isAndroid) {
      GeoFencingAndroid.registerWith();
    } else if (Platform.isIOS) {
      GeoFencingIos.registerWith();
    } else {
      throw UnsupportedError('Unsupported platform for GeoFencing');
    }

    _registered = true;
  }

  /// Initialize the geofencing plugin.
  ///
  /// This method must be called before using any other geofencing functionality.
  Future<void> initialize() {
    registerPlatforms();
    return GeoFencingPlatform.instance.initialize();
  }

  /// Register multiple geofences for monitoring.
  ///
  /// [regions] is a list of [GeoFenceRegion] objects that define the geofences
  /// to monitor. Each region must have a unique ID.
  Future<bool> registerGeoFences(List<GeoFenceRegion> regions) {
    return GeoFencingPlatform.instance.registerGeoFences(regions);
  }

  /// Remove a specific geofence by its ID.
  ///
  /// [id] is the unique identifier of the geofence to remove.
  Future<bool> removeGeoFence(String id) {
    return GeoFencingPlatform.instance.removeGeoFence(id);
  }

  /// Get a stream of geofence events.
  ///
  /// Returns a [Stream<GeoFenceEvent>] that emits events when the user enters
  /// or exits geofence regions.
  Stream<GeoFenceEvent> onEvent() {
    return GeoFencingPlatform.instance.onEvent();
  }
}
