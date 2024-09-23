package com.ridebeam.geospatial_arcore

import Coordinate
import GeospatialARCoreApi
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger

class MainActivity: FlutterActivity(), GeospatialARCoreApi {
    private val GEO_ACTIVITY_REQUEST_CODE = 1001
    private var resultCallback: ((Result<Coordinate>) -> Unit)? = null

    override fun startGeospatialARCoreSession(callback: (Result<Coordinate>) -> Unit) {
        resultCallback = callback
        callActivity()
    }

    private fun callActivity() {
        val binaryMessenger = getBinaryMessenger()
        BinaryMessengerManager.put("unique_identifier", binaryMessenger)
        startActivityForResult(
            Intent(this, GeoActivity::class.java)
                .putExtra("messenger", "unique_identifier"),
            GEO_ACTIVITY_REQUEST_CODE
        )
    }
    fun getBinaryMessenger(): BinaryMessenger? {
        return flutterEngine?.dartExecutor?.binaryMessenger
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == GEO_ACTIVITY_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            val latitude = data?.getDoubleExtra(GeoActivity.RESULT_LATITUDE, 0.0) ?: 0.0
            val longitude = data?.getDoubleExtra(GeoActivity.RESULT_LONGITUDE, 0.0) ?: 0.0
            val altitude = data?.getDoubleExtra(GeoActivity.RESULT_ALTITUDE, 0.0) ?: 0.0

            val coordinate = Coordinate(latitude, longitude, altitude)
            resultCallback?.invoke(Result.success(coordinate))
        } else {
            resultCallback?.invoke(Result.failure(Throwable("GeoActivity cancelled or failed")))
        }
        resultCallback = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeospatialARCoreApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }
}

object BinaryMessengerManager {
    private val messengers = mutableMapOf<String, BinaryMessenger?>()

    fun put(key: String, messenger: BinaryMessenger?) {
        messengers[key] = messenger
    }

    fun get(key: String): BinaryMessenger? {
        return messengers[key]
    }
}
