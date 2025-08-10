package com.geofencing.android

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices

data class GeoFenceRegion(
    val id: String,
    val latitude: Double,
    val longitude: Double,
    val radius: Float
)

object GeoFenceManager {
    private lateinit var context: Context
    private lateinit var geofencingClient: GeofencingClient
    private const val TAG = "GeoFenceManager"
    private const val GEOFENCE_ACTION = "com.geofencing.android.ACTION_GEOFENCE_EVENT"


    fun init(appContext: Context) {
        context = appContext
        geofencingClient = LocationServices.getGeofencingClient(context)
    }

    private fun checkInitialized() {
        if (!::context.isInitialized || !::geofencingClient.isInitialized) {
            throw IllegalStateException("GeoFenceManager is not initialized. Call init() first.")
        }
    }

    @SuppressLint("MissingPermission")
    fun registerGeofences(regions: List<GeoFenceRegion>): Boolean {
        checkInitialized()
        // Permission check
        val hasFineLocation = android.content.pm.PackageManager.PERMISSION_GRANTED ==
            context.checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)
        val hasBackgroundLocation = android.os.Build.VERSION.SDK_INT < 29 ||
            android.content.pm.PackageManager.PERMISSION_GRANTED ==
            context.checkSelfPermission("android.permission.ACCESS_BACKGROUND_LOCATION")
        if (!hasFineLocation || !hasBackgroundLocation) {
            Log.e(TAG, "Location permissions not granted.")
            return false
        }
        val geofenceList = regions.map { region ->
            Geofence.Builder()
                .setRequestId(region.id)
                .setCircularRegion(
                    region.latitude,
                    region.longitude,
                    region.radius
                )
                .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT)
                .setExpirationDuration(Geofence.NEVER_EXPIRE)
                .build()
        }

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofences(geofenceList)
            .build()

        val intent = Intent(context, GeofenceReceiver::class.java).apply {
            action = GEOFENCE_ACTION
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        geofencingClient.addGeofences(request, pendingIntent)
            .addOnSuccessListener { 
                Log.d(TAG, "Geofences registered successfully.")
                Log.d(TAG, "Registered geofences: ${regions.map { it.id }}")
            }
            .addOnFailureListener { e -> 
                Log.e(TAG, "Failed to register geofences: ${e.message}")
                Log.e(TAG, "Exception: ${e.javaClass.simpleName}")
            }
        return true
    }

    fun removeGeofence(id: String): Boolean {
        checkInitialized()
        try {
            geofencingClient.removeGeofences(listOf(id))
                .addOnSuccessListener { Log.d(TAG, "Geofence $id removed.") }
                .addOnFailureListener { e -> Log.e(TAG, "Failed to remove geofence: ${e.message}") }
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Exception removing geofence: ${e.message}")
            return false
        }
    }
}
