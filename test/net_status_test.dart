import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_status/net_status.dart';
import 'package:net_status/net_status_platform_interface.dart';
import 'package:net_status/net_status_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNetStatusPlatform
    with MockPlatformInterfaceMixin
    implements NetStatusPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> isConnected() {
    return Future.value(true);
  }

  @override
  Future<void> startListening() {
    return Future.value();
  }

  @override
  Future<void> stopListening() {
    return Future.value();
  }
}

void main() {
  final NetStatusPlatform initialPlatform = NetStatusPlatform.instance;

  setUp(() {
    NetStatusPlatform.instance = MockNetStatusPlatform();
  });
  test('$MethodChannelNetStatus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNetStatus>());
  });

  test('getPlatformVersion', () async {
    NetStatus netStatusPlugin = NetStatus();
    MockNetStatusPlatform fakePlatform = MockNetStatusPlatform();
    NetStatusPlatform.instance = fakePlatform;

    expect(await netStatusPlugin.getPlatformVersion(), '42');
  });

  test('startListening - iOS', () async {
    final NetStatus netStatus = NetStatus();
    // Create a mock that simulates iOS platform
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    // Should complete without throwing
    await expectLater(netStatus.startListening(), completes);
    debugDefaultTargetPlatformOverride = null;
  });

  test('startListening - unsupported platform', () async {
    final NetStatus netStatus = NetStatus();

    // Create a mock that simulates Android platform
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    // Should throw PlatformException
    expect(
      () => netStatus.startListening(),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'UNSUPPORTED_PLATFORM',
        ),
      ),
    );

    debugDefaultTargetPlatformOverride = null;
  });

  test('stopListening - iOS', () async {
    final NetStatus netStatus = NetStatus();

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    // Should complete without throwing
    await expectLater(netStatus.stopListening(), completes);

    debugDefaultTargetPlatformOverride = null;
  });

  test('stopListening - unsupported platform', () async {
    final NetStatus netStatus = NetStatus();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    // Should throw PlatformException
    expect(
      () => netStatus.stopListening(),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'UNSUPPORTED_PLATFORM',
        ),
      ),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  test('isConnected', () async {
    NetStatus netStatusPlugin = NetStatus();
    MockNetStatusPlatform fakePlatform = MockNetStatusPlatform();
    NetStatusPlatform.instance = fakePlatform;

    // Mock the isConnected method
    expect(await netStatusPlugin.isConnected(), true);
  });
}
