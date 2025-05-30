import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_status/net_status_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNetStatus platform = MethodChannelNetStatus();
  const MethodChannel channel = MethodChannel('net_status');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
  test('startListening', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'startListening') {
            return null; // Simulate successful start
          }
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method not implemented',
          );
        });

    await platform.startListening();
  });
  test('stopListening', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'stopListening') {
            return null; // Simulate successful stop
          }
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method not implemented',
          );
        });

    await platform.stopListening();
  });
  test('isConnected', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isConnected') {
            return true; // Simulate connected status
          }
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method not implemented',
          );
        });

    expect(await platform.isConnected(), true);
  });
  test('isConnected - false', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isConnected') {
            return false; // Simulate not connected status
          }
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method not implemented',
          );
        });

    expect(await platform.isConnected(), false);
  });
}
