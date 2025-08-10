# geo_fencing_android

Android implementation of the geo-fencing Flutter plugin. This package provides the native Android implementation for background location monitoring and geofence event handling.

## Overview

This package implements the geo-fencing functionality for Android using Google Play Services Location API. It provides:

- Background location monitoring
- Geofence entry and exit detection
- Proper permission handling
- System-level geofence management

## Features

- Native Android geofencing implementation
- Background location monitoring support
- Multiple geofence region support
- Real-time event broadcasting
- Proper Android lifecycle management
- Permission handling for location access

## Technical Implementation

### Core Components

- **GeoFenceManager**: Manages geofence registration and removal
- **GeofenceReceiver**: BroadcastReceiver for handling geofence events
- **GeoFencingAndroidPlugin**: Flutter plugin bridge

### Architecture

- Uses Google Play Services Geofencing API
- BroadcastReceiver pattern for event handling
- PendingIntent for system-level geofence management
- EventChannel for Flutter communication

## Android Requirements

- **Minimum SDK**: API 21 (Android 5.0+)
- **Target SDK**: Latest stable version
- **Permissions**: 
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION` (Android 10+)

## Usage

This package is automatically used by the main `flutter_geofence_manager` plugin when running on Android. No additional setup is required beyond the main plugin configuration.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

