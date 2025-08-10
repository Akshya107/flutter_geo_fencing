# Flutter Geo Fencing Manager

A cross-platform Flutter plugin for geofencing functionality that provides background location monitoring and geofence event handling for both Android and iOS platforms.

## 🏗️ Project Structure

This repository contains multiple packages organized as a federated plugin:

```
flutter_geo_fencing/
├── flutter_geo_fencing/           # Main plugin package
│   ├── lib/
│   │   └── flutter_geofence_manager.dart
│   └── example/                   # Example Flutter app
├── geo_fencing_android/           # Android platform implementation
│   ├── android/                   # Android-specific code
│   └── lib/
│       └── geo_fencing_android.dart
├── geo_fencing_ios/               # iOS platform implementation
│   ├── ios/                       # iOS-specific code
│   └── lib/
│       └── geo_fencing_ios.dart
└── geo_fencing_platform_interface/ # Platform interface
    └── lib/
        └── geo_fencing_platform_interface.dart
```

## 📱 Features

- **Cross-platform support**: Works on both Android and iOS
- **Background location monitoring**: Tracks user location even when app is in background
- **Geofence management**: Register, monitor, and remove geofence regions
- **Event handling**: Real-time notifications when entering/exiting geofence areas
- **Permission management**: Handles location permissions automatically

## 🚀 Getting Started

### Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_geofence_manager: latest
```

### Basic Usage

```dart
import 'package:flutter_geofence_manager/flutter_geofence_manager.dart';

// Initialize the plugin
await FlutterGeofenceManager.instance.initialize();

// Register geofences
final regions = [
  GeoFenceRegion(
    id: 'home',
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 100.0, // meters
  ),
];

await FlutterGeofenceManager.instance.registerGeoFences(regions);

// Listen to geofence events
FlutterGeofenceManager.instance.onEvent().listen((event) {
  print('Geofence event: ${event.id} - ${event.transitionType}');
});
```

## 🔧 Platform Requirements

### Android
- Minimum SDK: 23 (Android 6.0)
- Required permissions:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION`

### iOS
- Minimum iOS version: 12.0
- Required permissions:
  - `NSLocationWhenInUseUsageDescription`
  - `NSLocationAlwaysAndWhenInUseUsageDescription`

## 📋 Dependencies

- **geo_fencing_platform_interface**: ^1.0.1
- **geo_fencing_android**: ^1.0.2
- **geo_fencing_ios**: ^1.0.1

## 🐛 Recent Fixes

### Version 1.0.2
- Fixed Android build failure caused by deprecated package attribute in AndroidManifest.xml
- Updated namespace configuration for Android Gradle Plugin compatibility
- Resolved package declaration mismatches in Kotlin source files
- Cleaned up directory structure and removed duplicate files

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support and questions, please open an issue on the GitHub repository.
