package com.example.net_status

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.net.ConnectivityManager
import kotlinx.coroutines.*

/** NetStatusPlugin */
class NetStatusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private var isMonitoring = false

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "net_status")
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "net_status/events")
    eventChannel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      case "isConnected":
        val connectivityManager = flutterPluginBinding.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork = connectivityManager.activeNetworkInfo
        result.success(activeNetwork != null && activeNetwork.isConnected)
      case "startMonitoring":
        startNetworkMonitoring();
        result.success(null)
      case "stopMonitoring":
        stopNetworkMonitoring();
        result.success(null)
      default:
        result.notImplemented()
    }
  }

 override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    startNetworkMonitoring()
  }

  override fun onCancel(arguments: Any?) {
    stopNetworkMonitoring()
    eventSink = null
  }

  override fun startMonitoring() {
    // This method is called when the stream is listened to
    isMonitoring = true
    GlobalScope.launch(Dispatchers.Main) {
      while (isMonitoring) {
        val connectivityManager = flutterPluginBinding.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork = connectivityManager.activeNetworkInfo
        val isConnected = activeNetwork != null && activeNetwork.isConnected
        eventSink?.success(isConnected)
        delay(1000) // Check every second
      }
    }
  }
  override fun isConnected(): Boolean {
    val connectivityManager = flutterPluginBinding.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val activeNetwork = connectivityManager.activeNetworkInfo
    return activeNetwork != null && activeNetwork.isConnected
  }

  override fun stopMonitoring() {
    // This method is called when the stream is canceled
    isMonitoring = false
    eventSink?.endOfStream()
    eventSink = null
  }

  private fun sendConnectivityUpdate() {
      coroutineScope.launch {
          delay(100) // Small delay to allow network state to stabilize
          withContext(Dispatchers.Main) {
            eventSink?.success(getCurrentConnectivityInfo())           
          }
      }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    stopNetworkMonitoring()
    channel.setMethodCallHandler(null)
  }
}
