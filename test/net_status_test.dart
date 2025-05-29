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
}

void main() {
  final NetStatusPlatform initialPlatform = NetStatusPlatform.instance;

  test('$MethodChannelNetStatus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNetStatus>());
  });

  test('getPlatformVersion', () async {
    NetStatus netStatusPlugin = NetStatus();
    MockNetStatusPlatform fakePlatform = MockNetStatusPlatform();
    NetStatusPlatform.instance = fakePlatform;

    expect(await netStatusPlugin.getPlatformVersion(), '42');
  });
}
