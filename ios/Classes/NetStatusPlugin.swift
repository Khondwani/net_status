import Flutter
import UIKit
import Network

public class NetStatusPlugin: NSObject, FlutterPlugin {

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
    case "getNetworkStatus":
      result(getNetworkStatus())
    case "startMonitoring":
      startMonitoring()
      result("iOS Network monitoring started")
    case "stopMonitoring":
      stopMonitoring()
      result("iOS Network monitoring stopped")
    case "isConnected":
      result(isConnected())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) {
    self.eventSink = events
    startMonitoring()
  }

  public func onCancel(withArguments arguments: Any?) {
    stopMonitoring()
    self.eventSink = nil
  }
  
  public func startMonitoring() {
    guard !isMonitoring else { return }
    
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
    isMonitoring = true
  }

    private func sendConnectivityUpdate() {
        eventSink?(isConnected())
    }

  public func stopMonitoring() {
    guard isMonitoring else { return }
    
    pathMonitor?.cancel()
    pathMonitor = nil
    monitorQueue = nil
    isMonitoring = false
  }

  public func isConnected() -> Bool {
    guard let path = pathMonitor?.currentPath else {
      return "Unknown"
    }
    
    if path.status == .satisfied {
      return true
    } else {
      return false
    }
  }
}
