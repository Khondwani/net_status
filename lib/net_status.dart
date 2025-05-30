import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'net_status_platform_interface.dart';

class NetStatus {
  // This is what will be accessible to the dart code Its the public API of the plugin
  Future<String?> getPlatformVersion() {
    return NetStatusPlatform.instance.getPlatformVersion();
  }

  Future<void> startListening() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return NetStatusPlatform.instance.startListening();
      default:
        throw PlatformException(
          code: 'UNSUPPORTED_PLATFORM',
          message: 'This platform is not supported',
        );
    }
  }

  Future<void> stopListening() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return NetStatusPlatform.instance.stopListening();
      default:
        throw PlatformException(
          code: 'UNSUPPORTED_PLATFORM',
          message: 'This platform is not supported',
        );
    }
  }

  Future<bool> isConnected() {
    return NetStatusPlatform.instance.isConnected();
  }
}
