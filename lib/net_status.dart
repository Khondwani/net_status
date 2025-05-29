
import 'net_status_platform_interface.dart';

class NetStatus {
  Future<String?> getPlatformVersion() {
    return NetStatusPlatform.instance.getPlatformVersion();
  }
}
