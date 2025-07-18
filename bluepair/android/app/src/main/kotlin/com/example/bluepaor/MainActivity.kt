package com.example.bluepair

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "bluetooth_unpair"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Register plugins
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Set up MethodChannel for Bluetooth unpair
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "unpairDevice") {
                    val address = call.argument<String>("address")
                    try {
                        val adapter = BluetoothAdapter.getDefaultAdapter()
                        val device: BluetoothDevice? = adapter.getRemoteDevice(address)
                        val method = device?.javaClass?.getMethod("removeBond")
                        method?.invoke(device)
                        result.success(true)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("UNPAIR_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
