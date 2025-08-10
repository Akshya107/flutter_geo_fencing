package com.geofencing.android

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GeoFencingAndroidPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "geo_fencing_android/method")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "geo_fencing_android/event")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                GeofenceReceiver.eventSink = sink
            }

            override fun onCancel(args: Any?) {
                GeofenceReceiver.eventSink = null
            }
        })

        GeoFenceManager.init(context)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                result.success(null)
            }
            "registerGeoFences" -> {
                val regionMaps = call.argument<List<Map<String, Any>>>("regions") ?: emptyList()
                val regions = regionMaps.map { map ->
                    GeoFenceRegion(
                        id = map["id"].toString(),
                        latitude = (map["latitude"] as Number).toDouble(),
                        longitude = (map["longitude"] as Number).toDouble(),
                        radius = (map["radius"] as Number).toFloat()
                    )
                }
                val success = GeoFenceManager.registerGeofences(regions)
                result.success(success)
            }
            "removeGeoFence" -> {
                val id = call.argument<String>("id") ?: ""
                val success = GeoFenceManager.removeGeofence(id)
                result.success(success)
            }
            else -> result.notImplemented()
        }
    }
}
