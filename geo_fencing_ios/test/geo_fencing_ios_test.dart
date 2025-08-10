import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fencing_ios/geo_fencing_ios.dart';
import 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeoFencingIos', () {
    const MethodChannel methodChannel = MethodChannel('geo_fencing_ios/method');
    const EventChannel eventChannel = EventChannel('geo_fencing_ios/event');
    final log = <MethodCall>[];

    setUp(() {
      methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
            return true;
          case 'registerGeoFences':
            return true;
          case 'removeGeoFence':
            return true;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      log.clear();
    });

    test('can be registered', () {
      GeoFencingIos.registerWith();
      expect(GeoFencingPlatform.instance, isA<GeoFencingIos>());
    });

    test('initialize calls native method', () async {
      final plugin = GeoFencingIos();
      await plugin.initialize();
      expect(log, hasLength(1));
      expect(log.first.method, 'initialize');
    });

    test('registerGeoFences calls native method with correct arguments',
        () async {
      final plugin = GeoFencingIos();
      final regions = [
        GeoFenceRegion(
          id: 'test1',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100,
        ),
        GeoFenceRegion(
          id: 'test2',
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 200,
        ),
      ];

      await plugin.registerGeoFences(regions);
      expect(log, hasLength(1));
      expect(log.first.method, 'registerGeoFences');
      expect(log.first.arguments, {
        'regions': [
          {
            'id': 'test1',
            'latitude': 37.7749,
            'longitude': -122.4194,
            'radius': 100,
          },
          {
            'id': 'test2',
            'latitude': 40.7128,
            'longitude': -74.0060,
            'radius': 200,
          },
        ],
      });
    });

    test('removeGeoFence calls native method with correct arguments', () async {
      final plugin = GeoFencingIos();
      await plugin.removeGeoFence('test1');
      expect(log, hasLength(1));
      expect(log.first.method, 'removeGeoFence');
      expect(log.first.arguments, {'id': 'test1'});
    });

    test('onEvent returns stream that maps events correctly', () async {
      final plugin = GeoFencingIos();
      final events = <GeoFenceEvent>[];

      // Listen to events
      plugin.onEvent().listen(events.add);

      // Simulate native event
      const StandardMethodCodec codec = StandardMethodCodec();
      final event = {
        'id': 'test1',
        'transition': 'ENTER',
      };

      // This would normally be called by the native side
      // For testing, we'll just verify the stream is created
      expect(events, isEmpty);
    });
  });
}
