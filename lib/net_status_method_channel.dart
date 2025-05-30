import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'net_status_platform_interface.dart';

/// An implementation of [NetStatusPlatform] that uses method channels.
class MethodChannelNetStatus extends NetStatusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('net_status');
  final _eventChannel = const EventChannel('net_status_events');

  Stream<bool>? _connectivityStream;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> startListening() async {
    try {
      await methodChannel.invokeMethod('startListening');
    } on PlatformException catch (e) {
      throw Exception('Failed to start listening: ${e.message}');
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await methodChannel.invokeMethod('stopListening');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop listening: ${e.message}');
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final isConnected = await methodChannel.invokeMethod<bool>('isConnected');
      return isConnected ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to check connection status: ${e.message}');
    }
  }

  Stream<bool> get connectivityStream {
    _connectivityStream ??= _eventChannel.receiveBroadcastStream().map(
      (dynamic event) =>
          event is bool ? event : throw Exception('Invalid event type: $event'),
    );
    return _connectivityStream!;
  }
}
