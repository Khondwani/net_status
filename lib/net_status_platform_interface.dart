import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'net_status_method_channel.dart';

abstract class NetStatusPlatform extends PlatformInterface {
  /// Constructs a NetStatusPlatform.
  NetStatusPlatform() : super(token: _token);

  static final Object _token = Object();

  static NetStatusPlatform _instance = MethodChannelNetStatus();

  /// The default instance of [NetStatusPlatform] to use.
  ///
  /// Defaults to [MethodChannelNetStatus].
  static NetStatusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NetStatusPlatform] when
  /// they register themselves.
  static set instance(NetStatusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startListening() {
    throw UnimplementedError('startListening() has not been implemented.');
  }

  Future<void> stopListening() {
    throw UnimplementedError('stopListening() has not been implemented.');
  }

  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }
}
