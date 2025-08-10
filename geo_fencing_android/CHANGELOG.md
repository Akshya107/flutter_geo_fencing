# Changelog

## 1.0.2

* Bug Fixes
    - Fixed Android build failure caused by deprecated package attribute in AndroidManifest.xml
    - Updated namespace configuration for Android Gradle Plugin compatibility
    - Resolved package declaration mismatches in Kotlin source files
    - Cleaned up directory structure and removed duplicate files

## 1.0.1

* Updated README.md to reference the new main plugin name `flutter_geofence_manager`
* Updated GitHub URLs in pubspec.yaml for consistency
* Updated dependency to use `geo_fencing_platform_interface` ^1.0.1
* Improved documentation consistency across the plugin suite

## 1.0.0

* Initial release of the Android geo-fencing implementation
* Native Android geofencing using Google Play Services
* Background location monitoring support
* Geofence entry and exit detection
* Multiple geofence region support
* Proper permission handling for location access
* BroadcastReceiver pattern for event handling
* PendingIntent for system-level geofence management
