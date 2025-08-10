# flutter_geofence_manager

A cross-platform Flutter plugin for geofencing functionality. This plugin provides background location monitoring and geofence event handling for both Android and iOS platforms.

## Features

- ✅ **Cross-platform support** - Works on both Android and iOS
- ✅ **Background location monitoring** - Continues working when app is in background
- ✅ **Geofence entry and exit detection** - Real-time event notifications
- ✅ **Multiple geofence support** - Monitor multiple regions simultaneously
- ✅ **Proper permission handling** - Automatic permission requests
- ✅ **Privacy compliant** - Follows platform privacy guidelines

## Getting Started

### Prerequisites

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Flutter**: 3.10.0+

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_geofence_manager: ^1.0.0
```

### Platform Setup

#### Android

1. **Add location permissions** to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

2. **Request permissions** in your app:

```dart
import 'package:permission_handler/permission_handler.dart';

// Request location permissions
var status = await Permission.location.request();
if (status.isGranted) {
  status = await Permission.locationAlways.request();
}
```

#### iOS

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

## Usage

### Basic Usage

```dart
import 'package:flutter_geofence_manager/flutter_geofence_manager.dart';

class GeofencingService {
  final _geoFencing = FlutterGeoFencing.instance;

  Future<void> initialize() async {
    // Initialize the plugin    
    await _geoFencing.initialize();
    
    // Register geofences
    await _geoFencing.registerGeoFences([
      GeoFenceRegion(
        id: 'home',
        latitude: 37.7749,
        longitude: -122.4194,
        radius: 100, // meters
      ),
      GeoFenceRegion(
        id: 'office',
        latitude: 37.7849,
        longitude: -122.4094,
        radius: 50, // meters
      ),
    ]);
    
    // Listen to geofence events
    _geoFencing.onEvent().listen((event) {
      print('Geofence event: ${event.id} - ${event.transitionType}');
      
      switch (event.transitionType) {
        case TransitionType.enter:
          print('Entered ${event.id}');
          break;
        case TransitionType.exit:
          print('Exited ${event.id}');
          break;
      }
    });
  }
  
  Future<void> removeGeofence(String id) async {
    await _geoFencing.removeGeoFence(id);
  }
}
```

### Advanced Usage

```dart
import 'package:flutter_geofence_manager/flutter_geofence_manager.dart';

class GeofencingManager {
  final _geoFencing = FlutterGeoFencing.instance;
  StreamSubscription<GeoFenceEvent>? _eventSubscription;

  Future<void> startGeofencing() async {
    try {
      // Initialize
      await _geoFencing.initialize();
      
      // Register multiple geofences
      final regions = [
        GeoFenceRegion(
          id: 'home',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100,
        ),
        GeoFenceRegion(
          id: 'work',
          latitude: 37.7849,
          longitude: -122.4094,
          radius: 50,
        ),
        GeoFenceRegion(
          id: 'gym',
          latitude: 37.7649,
          longitude: -122.4294,
          radius: 75,
        ),
      ];
      
      await _geoFencing.registerGeoFences(regions);
      
      // Listen to events
      _eventSubscription = _geoFencing.onEvent().listen(
        (event) => _handleGeofenceEvent(event),
        onError: (error) => print('Geofence error: $error'),
      );
      
      print('Geofencing started successfully');
    } catch (e) {
      print('Failed to start geofencing: $e');
    }
  }
  
  void _handleGeofenceEvent(GeoFenceEvent event) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] Geofence: ${event.id} - ${event.transitionType}');
    
    // Handle different geofence events
    switch (event.id) {
      case 'home':
        _handleHomeEvent(event);
        break;
      case 'work':
        _handleWorkEvent(event);
        break;
      case 'gym':
        _handleGymEvent(event);
        break;
    }
  }
  
  void _handleHomeEvent(GeoFenceEvent event) {
    if (event.transitionType == TransitionType.enter) {
      print('Welcome home!');
      // Trigger home automation, notifications, etc.
    } else {
      print('Goodbye!');
    }
  }
  
  void _handleWorkEvent(GeoFenceEvent event) {
    if (event.transitionType == TransitionType.enter) {
      print('Arrived at work');
      // Start work mode, mute notifications, etc.
    } else {
      print('Left work');
      // End work mode, restore notifications, etc.
    }
  }
  
  void _handleGymEvent(GeoFenceEvent event) {
    if (event.transitionType == TransitionType.enter) {
      print('Time to work out!');
      // Start fitness tracking, etc.
    } else {
      print('Workout complete');
      // Stop fitness tracking, etc.
    }
  }
  
  Future<void> stopGeofencing() async {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    
    // Remove all geofences
    await _geoFencing.removeGeoFence('home');
    await _geoFencing.removeGeoFence('work');
    await _geoFencing.removeGeoFence('gym');
    
    print('Geofencing stopped');
  }
}
```

## API Reference

### FlutterGeoFencing

The main class for geofencing functionality.

#### Methods

- `initialize()` - Initialize the geofencing plugin
- `registerGeoFences(List<GeoFenceRegion> regions)` - Register multiple geofences
- `removeGeoFence(String id)` - Remove a specific geofence
- `onEvent()` - Get a stream of geofence events

### GeoFenceRegion

Represents a geofence region.

```dart
GeoFenceRegion({
  required String id,        // Unique identifier
  required double latitude,  // Latitude coordinate
  required double longitude, // Longitude coordinate
  required double radius,    // Radius in meters
})
```

### GeoFenceEvent

Represents a geofence event.

```dart
GeoFenceEvent({
  required String id,                    // Geofence ID
  required TransitionType transitionType, // ENTER or EXIT
})
```

### TransitionType

Enum for geofence transition types.

- `TransitionType.enter` - User entered the geofence
- `TransitionType.exit` - User exited the geofence

## Platform-Specific Notes

### Android

- Requires `ACCESS_FINE_LOCATION` and `ACCESS_BACKGROUND_LOCATION` permissions
- Background location permission must be requested separately on Android 10+
- Geofencing works reliably in the background

### iOS

- Requires "Always" location permission for background geofencing
- Permission flow: "When In Use" → "Always"
- Geofencing may be limited when app is in background due to iOS restrictions

## Error Handling

```dart
try {
  await _geoFencing.initialize();
  await _geoFencing.registerGeoFences(regions);
} catch (e) {
  if (e.toString().contains('PERMISSION_DENIED')) {
    print('Location permission denied');
    // Handle permission error
  } else {
    print('Geofencing error: $e');
    // Handle other errors
  }
}
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure location permissions are granted
   - For Android 10+, request background location separately
   - For iOS, ensure "Always" permission is granted

2. **Events Not Triggering**
   - Check if device location services are enabled
   - Verify geofence coordinates and radius
   - Ensure app has proper background permissions

3. **Background Limitations**
   - iOS may limit background geofencing
   - Android requires background location permission

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 