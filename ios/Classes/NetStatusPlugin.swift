import Flutter
import UIKit
import Network
import SystemConfiguration

public class NetStatusPlugin: NSObject, FlutterPlugin, FlutterStreamHandler  {
// add FlutterStreamHandler to handle event streams
    private var pathMonitor: NWPathMonitor? 
    private var monitorQueue: DispatchQueue?
    private var isMonitoring: Bool = false
    private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "net_status", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "net_status/events", binaryMessenger: registrar.messenger())
    let instance = NetStatusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "startListening": // these names should mart the DART SIDE in the methodchannelNet file
      startMonitoring()
      result("iOS Network monitoring started")
    case "stopListening":
      stopMonitoring()
      result("iOS Network monitoring stopped")
    case "isConnected":
      result(isConnected())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    startMonitoring()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopMonitoring()
    self.eventSink = nil
    return nil
  }

  public func startMonitoring() {
    guard !isMonitoring else { return }
    isMonitoring = true
    monitorQueue = DispatchQueue(label: "NetworkMonitor")
    pathMonitor = NWPathMonitor()
    
    pathMonitor?.pathUpdateHandler = { [weak self] path in
      if path.status == .satisfied {
        print("Connected to the network")
       
      } else {
        print("No network connection")
       
      }
      DispatchQueue.main.async {
        self?.sendConnectivityUpdate()
      }
    }
    
    pathMonitor?.start(queue: monitorQueue!)
  }

  private func sendConnectivityUpdate() {
        eventSink?(isConnected())
  }

  public func stopMonitoring() {
    guard isMonitoring else { return }
    isMonitoring = false

    pathMonitor?.cancel()
    pathMonitor = nil
    monitorQueue = nil
    
  }

  public func isConnected() -> Bool {
    guard let path = pathMonitor?.currentPath else {
      return false
    }
    
    if path.status == .satisfied {
      // Check specific connection types
      let usesWifi = path.usesInterfaceType(.wifi)
      let usesCellular = path.usesInterfaceType(.cellular)
      
      // Return true if connected via WiFi or cellular
      return usesWifi || usesCellular
    } else {
      return false
    }
  }
}
