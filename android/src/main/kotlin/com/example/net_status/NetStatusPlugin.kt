package com.example.net_status

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.net.ConnectivityManager
import kotlinx.coroutines.*
import android.net.*

/** NetStatusPlugin */
class NetStatusPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler  {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private var connectivityManager: ConnectivityManager? = null
  private var eventSink: EventChannel.EventSink? = null
  private var isMonitoring = false
  private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "net_status")
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "net_status/events")
    eventChannel.setStreamHandler(this)
    connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "isConnected" -> {
        val activeNetwork = connectivityManager?.activeNetworkInfo
        result.success(activeNetwork != null && activeNetwork.isConnected)
      }
      "startListening" -> {
        startMonitoring()
        result.success(null)
      }
        
      "stopListening" -> {
        stopMonitoring();
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    startMonitoring()
  }

  override fun onCancel(arguments: Any?) {
    stopMonitoring()
    eventSink = null
  }

  fun startMonitoring() {
    // This method is called when the stream is listened to
    isMonitoring = true
    GlobalScope.launch(Dispatchers.Main) {
      while (isMonitoring) {
      
        val activeNetwork = connectivityManager?.activeNetworkInfo
        val isConnected = activeNetwork != null && activeNetwork.isConnected
        eventSink?.success(isConnected)
        delay(1000) // Check every second
      }
    }
  }
  fun isConnected(): Boolean {
    
    val activeNetwork = connectivityManager?.activeNetworkInfo
    return activeNetwork != null && activeNetwork.isConnected
  }

  fun stopMonitoring() {
    // This method is called when the stream is canceled
    isMonitoring = false
    eventSink?.endOfStream()
    eventSink = null
  }

  private fun sendConnectivityUpdate() {
      coroutineScope.launch {
          delay(100) // Small delay to allow network state to stabilize
          withContext(Dispatchers.Main) {
            eventSink?.success(isConnected())           
          }
      }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    stopMonitoring()
    
  }
}
