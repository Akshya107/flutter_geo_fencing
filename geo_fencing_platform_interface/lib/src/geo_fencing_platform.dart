import 'package:geo_fencing_platform_interface/src/models/geo_fence_region.dart';
import 'package:geo_fencing_platform_interface/src/models/geo_fence_event.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class GeoFencingPlatform extends PlatformInterface {
  GeoFencingPlatform() : super(token: _token);

  static final Object _token = Object();

  static GeoFencingPlatform _instance = _DefaultGeoFencingPlatform();

  static GeoFencingPlatform get instance => _instance;

  static set instance(GeoFencingPlatform platform) {
    PlatformInterface.verifyToken(platform, _token);
    _instance = platform;
  }

  Future<void> initialize();
  Future<bool> registerGeoFences(List<GeoFenceRegion> regions);
  Future<bool> removeGeoFence(String id);
  Stream<GeoFenceEvent> onEvent();
}

class _DefaultGeoFencingPlatform extends GeoFencingPlatform {
  @override
  Future<void> initialize() async {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  @override
  Future<bool> registerGeoFences(List<GeoFenceRegion> regions) async {
    throw UnimplementedError('registerGeofences() has not been implemented.');
  }

  @override
  Future<bool> removeGeoFence(String id) async {
    throw UnimplementedError('removeGeofence() has not been implemented.');
  }

  @override
  Stream<GeoFenceEvent> onEvent() {
    throw UnimplementedError('onEvent() has not been implemented.');
  }
}
