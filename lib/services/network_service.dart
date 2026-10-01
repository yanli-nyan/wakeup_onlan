import 'dart:io';

class NetworkService {
  static const int _timeoutSeconds = 3;
  static const int _wolPort = 9;

  static Future<bool> checkPort(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: _timeoutSeconds),
      );
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPcOnline(String host) async {
    final port8080 = await checkPort(host, 8080);
    return port8080;
  }

  static Future<bool> isOnTailscaleNetwork() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (_isTailscaleIp(addr.address)) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isOnLocalNetwork() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (_isLocalIp(addr.address)) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canWakePc() async {
    final onTailscale = await isOnTailscaleNetwork();
    if (onTailscale) return true;
    final onLocal = await isOnLocalNetwork();
    return onLocal;
  }

  static Future<void> sendMagicPacket(
    String macAddress, {
    String? broadcastAddress,
  }) async {
    try {
      final macBytes = _parseMacAddress(macAddress);
      final packet = _buildMagicPacket(macBytes);

      final address = broadcastAddress ?? '255.255.255.255';

      final rawDgram = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      rawDgram.broadcastEnabled = true;
      rawDgram.send(packet, InternetAddress(address), _wolPort);
      rawDgram.close();
    } catch (e) {
      // ignore
    }
  }

  static List<int> _buildMagicPacket(List<int> macBytes) {
    final packet = <int>[];

    for (int i = 0; i < 6; i++) {
      packet.add(0xFF);
    }

    for (int i = 0; i < 16; i++) {
      packet.addAll(macBytes);
    }

    return packet;
  }

  static List<int> _parseMacAddress(String mac) {
    final clean = mac.replaceAll(RegExp(r'[:\-]'), '');
    final bytes = <int>[];

    for (int i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }

    if (bytes.length != 6) {
      throw const FormatException('Invalid MAC address');
    }

    return bytes;
  }

  static bool _isTailscaleIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);

    if (first == null || second == null) return false;

    if (first != 100) return false;
    if (second < 64 || second > 127) return false;

    return true;
  }

  static bool _isLocalIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);

    if (first == null || second == null || third == null) return false;

    if (first == 192 && second == 168 && third == 1) {
      return true;
    }

    return false;
  }
}
