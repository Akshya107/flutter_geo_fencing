# geo_fencing_ios

A Flutter plugin for iOS geofencing functionality. This plugin provides background location monitoring and geofence event handling for iOS applications.

## Features

- ✅ Background location monitoring
- ✅ Geofence entry and exit event detection
- ✅ Multiple geofence support
- ✅ Proper iOS permission handling
- ✅ Privacy manifest compliance

## Getting Started

### Prerequisites

- iOS 12.0 or higher
- Location permissions (Always) for background geofencing

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  geo_fencing_ios: ^1.0.0
```

### iOS Setup

1. **Add location permissions** to your `ios/Runner/Info.plist`:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs background location access for geofencing.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location to trigger geofence events.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

2. **Request permissions** in your app:

```dart
import 'package:permission_handler/permission_handler.dart';

// Request location permissions
var status = await Permission.locationWhenInUse.request();
if (status.isGranted) {
  status = await Permission.locationAlways.request();
}
```

### Usage

```dart
import 'package:geo_fencing_ios/geo_fencing_ios.dart';
import 'package:geo_fencing_platform_interface/geo_fencing_platform_interface.dart';

// Initialize the plugin
final geoFencing = GeoFencingIos();
await geoFencing.initialize();

// Register geofences
await geoFencing.registerGeoFences([
  GeoFenceRegion(
    id: 'home',
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 100, // meters
  ),
]);

// Listen to geofence events
geoFencing.onEvent().listen((event) {
  print('Geofence event: ${event.id} - ${event.transitionType}');
});

// Remove a geofence
await geoFencing.removeGeoFence('home');
```

## API Reference

### Methods

- `initialize()` - Initialize the geofencing plugin
- `registerGeoFences(List<GeoFenceRegion> regions)` - Register multiple geofences
- `removeGeoFence(String id)` - Remove a specific geofence
- `onEvent()` - Stream of geofence events

### Models

- `GeoFenceRegion` - Represents a geofence with id, latitude, longitude, and radius
- `GeoFenceEvent` - Represents a geofence event with id and transition type

## Platform Interface

This plugin implements the `geo_fencing_platform_interface` package, which provides a unified API for geofencing across different platforms.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

