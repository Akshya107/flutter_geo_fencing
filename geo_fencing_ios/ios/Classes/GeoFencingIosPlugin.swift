import Flutter
import UIKit
import CoreLocation


public class GeoFencingIosPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, FlutterStreamHandler {
    var locationManager: CLLocationManager?
    var eventSink: FlutterEventSink?
    var monitoredRegions: [String: CLCircularRegion] = [:]
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    print("GeoFencingIosPlugin: register called")
    let channel = FlutterMethodChannel(name: "geo_fencing_ios/method", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name:"geo_fencing_ios/event", binaryMessenger: registrar.messenger())
    let instance = GeoFencingIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
    print("GeoFencingIosPlugin: registration completed")
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("GeoFencingIosPlugin: handle method called: \(call.method)")
        
        switch call.method {
        case "initialize":
            print("GeoFencingIosPlugin: initialize method called")
            self.setupLocationManager()
            result(true)

        case "registerGeoFences":
            print("GeoFencingIosPlugin: registerGeoFences method called")
            if let args = call.arguments as? [String: Any],
               let regionsData = args["regions"] as? [[String: Any]] {
               let success = self.registerGeoFences(regionsData: regionsData)
                result(success)
            } else {
                print("GeoFencingIosPlugin: Invalid arguments for registerGeoFences")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for registerGeoFences", details: nil))
            }

        case "removeGeoFence":
            print("GeoFencingIosPlugin: removeGeoFence method called")
            if let args = call.arguments as? [String: Any],
               let id = args["id"] as? String {
               let success = self.removeGeoFence(id: id)
               result(success)
            } else {
                print("GeoFencingIosPlugin: Invalid arguments for removeGeoFence")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for removeGeoFence", details: nil))
            }

        case "checkAuthorizationStatus":
            print("GeoFencingIosPlugin: checkAuthorizationStatus method called")
            let status = CLLocationManager.authorizationStatus()
            print("GeoFencingIosPlugin: Current authorization status: \(status.rawValue)")
            result(status.rawValue)

        default:
            print("GeoFencingIosPlugin: Unknown method: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    func setupLocationManager() {
        print("GeoFencingIosPlugin: setupLocationManager called")
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        print("GeoFencingIosPlugin: Setting up location manager...")
        
        // Check current authorization status
        let currentStatus = CLLocationManager.authorizationStatus()
        print("GeoFencingIosPlugin: Current authorization status: \(currentStatus.rawValue)")
        
        switch currentStatus {
        case .notDetermined:
            print("GeoFencingIosPlugin: Requesting when in use authorization...")
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("GeoFencingIosPlugin: Already have when in use authorization, requesting always...")
            locationManager?.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("GeoFencingIosPlugin: Already have always authorization - ready for geofencing")
        case .denied, .restricted:
            print("GeoFencingIosPlugin: Location access denied or restricted")
            if let sink = eventSink {
                sink(FlutterError(code: "PERMISSION_DENIED", message: "Location permission denied", details: nil))
            }
        @unknown default:
            print("GeoFencingIosPlugin: Unknown authorization status")
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        print("GeoFencingIosPlugin: Authorization status changed to: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse:
            print("GeoFencingIosPlugin: Got WhenInUse permission — checking if we need Always...")
            // Only request Always if we don't already have it
            // This prevents downgrading from Always to WhenInUse
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                manager.requestAlwaysAuthorization()
            } else {
                print("GeoFencingIosPlugin: Already have Always permission - ready for geofencing")
            }

        case .authorizedAlways:
            print("GeoFencingIosPlugin: Got Always permission — ready to register geofence.")

        case .denied, .restricted:
            print("GeoFencingIosPlugin: Permission denied or restricted.")
            if let sink = eventSink {
                sink(FlutterError(code: "PERMISSION_DENIED", message: "Location permission denied", details: nil))
            }
        case .notDetermined:
            print("GeoFencingIosPlugin: Permission not determined yet.")
        @unknown default:
            print("GeoFencingIosPlugin: Unknown authorization status")
        }
    }

    func registerGeoFences(regionsData: [[String: Any]]) -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        print("GeoFencingIosPlugin: registerGeoFences called, auth status: \(authStatus.rawValue)")
        
        if authStatus != .authorizedAlways {
            print("GeoFencingIosPlugin: Cannot register geofences - need Always authorization. Current status: \(authStatus.rawValue)")
            return false
        }
        
        for regionData in regionsData {
            if let id = regionData["id"] as? String,
               let latitude = regionData["latitude"] as? Double,
               let longitude = regionData["longitude"] as? Double,
               let radius = regionData["radius"] as? Double {
                registerGeoFence(id: id, latitude: latitude, longitude: longitude, radius: radius)
            }
        }
        return true
    }
    
    func registerGeoFence(id: String, latitude: Double, longitude: Double, radius: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: id)
        region.notifyOnEntry = true
        region.notifyOnExit = true

        monitoredRegions[id] = region
        locationManager?.startMonitoring(for: region)
        print("GeoFencingIosPlugin: Registered geofence: \(id) at (\(latitude), \(longitude)) with radius \(radius)")
    }
    
    func removeGeoFence(id: String) -> Bool {
        if let region = monitoredRegions[id] {
               locationManager?.stopMonitoring(for: region)
               monitoredRegions.removeValue(forKey: id)
               print("GeoFencingIosPlugin: Removed geofence: \(id)")
               return true // Successfully removed
           } else {
               print("GeoFencingIosPlugin: Geofence not found for removal: \(id)")
               return false // Geofence wasn't found/monitored
           }
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("GeoFencingIosPlugin: Did enter region: \(region.identifier)")
        sendEvent(type: "ENTER", region: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("GeoFencingIosPlugin: Did exit region: \(region.identifier)")
        sendEvent(type: "EXIT", region: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("GeoFencingIosPlugin: Monitoring failed for region: \(region?.identifier ?? "unknown"), error: \(error.localizedDescription)")
    }

    func sendEvent(type: String, region: CLRegion) {
        guard let sink = eventSink else { 
            print("GeoFencingIosPlugin: No event sink available")
            return 
        }
        let event: [String: Any] = [
            "id": region.identifier,
            "transition": type
        ]
        print("GeoFencingIosPlugin: Sending geofence event: \(event)")
        sink(event)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("GeoFencingIosPlugin: Event stream listener attached")
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("GeoFencingIosPlugin: Event stream listener cancelled")
        self.eventSink = nil
        return nil
    }
}
