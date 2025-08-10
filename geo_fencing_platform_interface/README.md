# geo_fencing_platform_interface

A platform interface for the geo-fencing Flutter plugin. This package provides the abstract interface that platform-specific implementations must implement.

## Overview

This package defines the contract for geo-fencing functionality across different platforms (Android, iOS, etc.). It provides:

- Abstract base classes for geo-fencing operations
- Data models for geo-fence regions and events
- Platform interface verification and error handling

## Features

- Platform-agnostic geo-fencing interface
- Type-safe data models
- Proper error handling for unimplemented methods
- Support for multiple geo-fence regions
- Real-time event streaming

## Usage

This package is primarily used by platform-specific implementations and the main geo-fencing plugin. For end users, see the main `flutter_geofence_manager` package.

## API Reference

### GeoFencingPlatform

The main abstract class that defines the geo-fencing interface:

- `initialize()` - Initialize the geo-fencing system
- `registerGeoFences(List<GeoFenceRegion> regions)` - Register geo-fence regions
- `removeGeofence(String id)` - Remove a specific geo-fence
- `onEvent()` - Stream of geo-fence events

### Data Models

- `GeoFenceRegion` - Represents a geo-fence region with coordinates and radius
- `GeoFenceEvent` - Represents a geo-fence entry/exit event
- `TransitionType` - Enum for enter/exit transitions

## Platform Implementation

To implement this interface for a new platform:

1. Extend `GeoFencingPlatform`
2. Implement all abstract methods
3. Register your implementation with the platform interface

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
