import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_geofence_manager/flutter_geofence_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  ;

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      debugPrint('Notification tapped: ${response.payload}');
    },
  );

  runApp(GeoFencingExampleApp(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  ));
}

class GeoFencingExampleApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const GeoFencingExampleApp(
      {super.key, required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GeoFencing Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: GeoFencingHomePage(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin),
    );
  }
}

class GeoFencingHomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const GeoFencingHomePage(
      {super.key, required this.flutterLocalNotificationsPlugin});

  @override
  State<GeoFencingHomePage> createState() => _GeoFencingHomePageState();
}

class _GeoFencingHomePageState extends State<GeoFencingHomePage> {
  final FlutterGeofenceManager _geoFencing = FlutterGeofenceManager.instance;

  bool _isInitialized = false;
  bool _isMonitoring = false;
  List<GeoFenceEvent> events = [];
  StreamSubscription<GeoFenceEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGeoFencing();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeGeoFencing() async {
    try {
      await _geoFencing.initialize();

      // Request notification permissions
      await _requestNotificationPermissions();

      if (Platform.isAndroid) {
        final hasPermissions = await _requestAndroidPermissions();
        if (!hasPermissions) {
          _showSnackBar('Location permissions required for geofencing');
          return;
        }
      } else if (Platform.isIOS) {
        // For iOS, request notification permission
        // iOS permissions are handled automatically by the system
        debugPrint(
            'iOS notification permissions will be requested by the system');
      }
      setState(() {
        _isInitialized = true;
      });
      _listenToEvents();
      await _startMonitoring();
    } catch (e) {
      debugPrint('Failed to initialize geofencing: $e');
      _showSnackBar('Failed to initialize geofencing: $e');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+, request notification permission
        if (await widget.flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>() !=
            null) {
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              widget.flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>();

          final bool? granted =
              await androidImplementation?.requestNotificationsPermission();
          debugPrint('Android notification permission granted: $granted');
        }
      } else if (Platform.isIOS) {
        // For iOS, request notification permission
        // iOS permissions are handled automatically by the system
        debugPrint(
            'iOS notification permissions will be requested by the system');
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  Future<bool> _requestAndroidPermissions() async {
    try {
      // Request location permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationAlways,
        Permission.locationWhenInUse,
      ].request();

      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        debugPrint('All location permissions granted');
        return true;
      } else {
        debugPrint('Some permissions denied: $statuses');

        // Show dialog explaining why permissions are needed
        bool shouldOpenSettings = await _showPermissionDialog();
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Location Permissions Required'),
              content: Text(
                'Geofencing requires location permissions to work properly. '
                'Please grant location permissions in app settings.',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Open Settings'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _listenToEvents() {
    debugPrint("UI: Subscribing to plugin stream");
    _eventSubscription = _geoFencing.onEvent().listen(
      (event) {
        setState(() {
          events.add(event);
        });
        debugPrint(
            "UI: Received event ${event.id}-----${event.transitionType}");

        // Show notification for the geofence event
        _showGeofenceNotification(event);
      },
      onError: (error) => debugPrint("UI: Stream error: $error"),
      onDone: () => debugPrint("UI: Stream done"),
    );
  }

  Future<void> _startMonitoring() async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization to complete');
      return;
    }
    try {
      final regions = [
        GeoFenceRegion(
          id: 'home',
          latitude: 37.7749, // San Francisco coordinates as example
          longitude: -122.4194,
          radius: 100.0, // 100 meters
        ),
        GeoFenceRegion(
          id: 'testing',
          latitude: 28.67388, // San Francisco coordinates as example
          longitude: 77.376271,
          radius: 50.0, // 100 meters
        ),
        GeoFenceRegion(
          id: 'office',
          latitude: 37.7849,
          longitude: -122.4094,
          radius: 200.0, // 200 meters
        ),
      ];

      bool status = await _geoFencing.registerGeoFences(regions);
      setState(() {
        _isMonitoring = status;
      });
      _showSnackBar('Started monitoring ${regions.length} geofences');
    } catch (e) {
      _showSnackBar('Failed to start monitoring: $e');
    }
  }

  Future<void> _stopMonitoring() async {
    try {
      // Remove all geofences
      await _geoFencing.removeGeoFence('home');
      await _geoFencing.removeGeoFence('office');

      setState(() {
        _isMonitoring = false;
        events.clear();
      });
      _showSnackBar('Stopped monitoring geofences');
    } catch (e) {
      _showSnackBar('Failed to stop monitoring: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showGeofenceNotification(GeoFenceEvent event) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Events',
      channelDescription: 'Notifications for geofence enter/exit events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String title =
        '${event.transitionType.name.toUpperCase()} - ${event.id}';
    final String body = 'Lat: ${event.latitude.toStringAsFixed(4)}, '
        'Lng: ${event.longitude.toStringAsFixed(4)}\n'
        'Time: ${event.timestamp.toLocal()}';

    await widget.flutterLocalNotificationsPlugin.show(
      event.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: 'geofence_${event.id}_${event.transitionType.name}',
    );

    debugPrint(
        'Notification shown for geofence event: ${event.id} - ${event.transitionType.name}');
  }

  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications for debugging',
      importance: Importance.none,
      priority: Priority.low,
      showWhen: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSDetails,
    );

    await widget.flutterLocalNotificationsPlugin.show(
      999, // Test notification ID
      'Test Notification',
      'This is a test notification to verify the notification system is working!',
      platformChannelSpecifics,
      payload: 'test_notification',
    );

    debugPrint('Test notification shown');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter GeoFencing Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text('Initialized: ${_isInitialized ? "Yes" : "No"}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isMonitoring
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _isMonitoring ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text('Monitoring: ${_isMonitoring ? "Yes" : "No"}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized && !_isMonitoring
                        ? _startMonitoring
                        : null,
                    child: const Text('Start Monitoring'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isMonitoring ? _stopMonitoring : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Stop Monitoring'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Test Notification Button
            ElevatedButton.icon(
              onPressed: () => _showTestNotification(),
              icon: const Icon(Icons.notifications),
              label: const Text('Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Geofence Events (${events.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: events.isEmpty
                          ? const Center(
                              child: Text(
                                'No events yet. Start monitoring to see geofence events.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return ListTile(
                                  leading: Icon(
                                    event.transitionType == TransitionType.enter
                                        ? Icons.login
                                        : Icons.logout,
                                    color: event.transitionType ==
                                            TransitionType.enter
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  title: Text(
                                      '${event.transitionType.name.toUpperCase()} - ${event.id}'),
                                  subtitle: Text(
                                    'Lat: ${event.latitude.toStringAsFixed(4)}, '
                                    'Lng: ${event.longitude.toStringAsFixed(4)}\n'
                                    'Time: ${event.timestamp.toLocal()}',
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
