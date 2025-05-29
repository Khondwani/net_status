import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'net_status_platform_interface.dart';

/// An implementation of [NetStatusPlatform] that uses method channels.
class MethodChannelNetStatus extends NetStatusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('net_status');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
