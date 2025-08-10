package com.geofencing.android

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import io.flutter.plugin.common.EventChannel

private const val GEOFENCE_ACTION = "com.geofencing.android.ACTION_GEOFENCE_EVENT"

class GeofenceReceiver : BroadcastReceiver() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d("GeofenceReceiver", "onReceive called with intent action: ${intent?.action}")
        Log.d("GeofenceReceiver", "Intent extras: ${intent?.extras}")

        if (intent?.action != GEOFENCE_ACTION) {
            Log.w("GeofenceReceiver", "Ignoring intent with unexpected action: ${intent?.action}")
            return
        }

        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent == null) {
            Log.e("GeofenceReceiver", "GeofencingEvent is null!")
            Log.e("GeofenceReceiver", "Intent data: ${intent.dataString}")
            Log.e("GeofenceReceiver", "Intent categories: ${intent.categories}")
            Log.e("GeofenceReceiver", "Intent flags: ${intent.flags}")

            eventSink?.success(mapOf("error" to "GeofencingEvent is null - intent may be malformed"))
            return
        }

        if (geofencingEvent.hasError()) {
            val errorMessage = "Geofencing error: ${geofencingEvent.errorCode}"
            Log.e("GeofenceReceiver", errorMessage)
            eventSink?.success(mapOf("error" to errorMessage))
            return
        }

        val transition = geofencingEvent.geofenceTransition
        Log.d("GeofenceReceiver", "Geofence transition type: $transition")

        val transitionString = when (transition) {
            Geofence.GEOFENCE_TRANSITION_ENTER, 1 -> "ENTER"
            Geofence.GEOFENCE_TRANSITION_EXIT, 2 -> "EXIT"
            else -> {
                Log.w("GeofenceReceiver", "Unknown transition: $transition")
                eventSink?.success(mapOf("error" to "Unknown transition: $transition"))
                return
            }
        }

        geofencingEvent.triggeringGeofences?.forEach { geofence ->
            Log.d("GeofenceReceiver", "Geofence triggered: ${geofence.requestId}")
            Log.d("GeofenceReceiver", "Geofence triggered: \"transition\" to ${transitionString}")
            eventSink?.success(
                mapOf("id" to geofence.requestId, "transition" to transitionString)
            )
        }
    }
}
