import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

class SshShell {
  final SSHClient client;
  final SSHSession session;
  final Stream<Uint8List> output;

  SshShell({required this.client, required this.session, required this.output});

  void write(String data) {
    session.write(Uint8List.fromList(utf8.encode(data)));
  }

  void writeBytes(Uint8List data) {
    session.write(data);
  }

  Future<void> close() async {
    session.close();
    await session.done;
    client.close();
    await client.done;
  }
}

class SshService {
  static Future<String> runCommand({
    required String host,
    int port = 22,
    required String username,
    required String password,
    required String command,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final socket = await SSHSocket.connect(host, port, timeout: timeout);

    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );

    try {
      final result = await client.run(command);
      return utf8.decode(result).trim();
    } finally {
      client.close();
      await client.done;
    }
  }

  static Future<String> runCommandViaJump({
    required String jumpHost,
    int jumpPort = 22,
    required String jumpUsername,
    required String jumpPassword,
    required String targetHost,
    int targetPort = 22,
    required String targetUsername,
    required String targetPassword,
    required String command,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final jumpSocket = await SSHSocket.connect(
      jumpHost,
      jumpPort,
      timeout: timeout,
    );

    final jumpClient = SSHClient(
      jumpSocket,
      username: jumpUsername,
      onPasswordRequest: () => jumpPassword,
    );

    try {
      final forwardSocket = await jumpClient.forwardLocal(
        targetHost,
        targetPort,
      );

      final targetClient = SSHClient(
        forwardSocket,
        username: targetUsername,
        onPasswordRequest: () => targetPassword,
      );

      try {
        final result = await targetClient.run(command);
        return utf8.decode(result).trim();
      } finally {
        targetClient.close();
        await targetClient.done;
      }
    } finally {
      jumpClient.close();
      await jumpClient.done;
    }
  }

  static Future<SshShell> openShell({
    required String host,
    int port = 22,
    required String username,
    required String password,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final socket = await SSHSocket.connect(host, port, timeout: timeout);

    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );

    final session = await client.shell(
      pty: const SSHPtyConfig(type: 'xterm-256color', width: 80, height: 24),
    );

    final output = session.stdout.asBroadcastStream();

    return SshShell(client: client, session: session, output: output);
  }

  static Future<SshShell> openShellViaJump({
    required String jumpHost,
    int jumpPort = 22,
    required String jumpUsername,
    required String jumpPassword,
    required String targetHost,
    int targetPort = 22,
    required String targetUsername,
    required String targetPassword,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final jumpSocket = await SSHSocket.connect(
      jumpHost,
      jumpPort,
      timeout: timeout,
    );

    final jumpClient = SSHClient(
      jumpSocket,
      username: jumpUsername,
      onPasswordRequest: () => jumpPassword,
    );

    final forwardSocket = await jumpClient.forwardLocal(targetHost, targetPort);

    final targetClient = SSHClient(
      forwardSocket,
      username: targetUsername,
      onPasswordRequest: () => targetPassword,
    );

    final session = await targetClient.shell(
      pty: const SSHPtyConfig(type: 'xterm-256color', width: 80, height: 24),
    );

    final output = session.stdout.asBroadcastStream();

    return SshShell(client: targetClient, session: session, output: output);
  }
}
