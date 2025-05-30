import 'net_status_platform_interface.dart';

class NetStatus {
  // This is what will be accessible to the dart code Its the public API of the plugin
  Future<String?> getPlatformVersion() {
    return NetStatusPlatform.instance.getPlatformVersion();
  }

  Future<void> startListening() {
    return NetStatusPlatform.instance.startListening();
  }

  Future<void> stopListening() {
    return NetStatusPlatform.instance.stopListening();
  }

  Future<bool> isConnected() {
    return NetStatusPlatform.instance.isConnected();
  }

  Stream<bool> get connectivityStream {
    return NetStatusPlatform
        .instance
        .connectivityStream; // this will get from our method channel file
  }
}
