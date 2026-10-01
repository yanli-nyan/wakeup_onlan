import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import '../services/ssh_service.dart';

const _greenScreenTheme = TerminalTheme(
  cursor: Color(0XFF33FF33),
  selection: Color(0X5533FF33),
  foreground: Color(0XFF33FF33),
  background: Color(0XFF000000),
  black: Color(0XFF003300),
  red: Color(0XFF00AA00),
  green: Color(0XFF00FF00),
  yellow: Color(0XFF00FF00),
  blue: Color(0XFF00AA00),
  magenta: Color(0XFF00FF00),
  cyan: Color(0XFF00FF00),
  white: Color(0XFF33FF33),
  brightBlack: Color(0XFF005500),
  brightRed: Color(0XFF00FF00),
  brightGreen: Color(0XFF33FF33),
  brightYellow: Color(0XFF33FF33),
  brightBlue: Color(0XFF00FF00),
  brightMagenta: Color(0XFF33FF33),
  brightCyan: Color(0XFF33FF33),
  brightWhite: Color(0XFF99FF99),
  searchHitBackground: Color(0X55FFFFFF),
  searchHitBackgroundCurrent: Color(0XAAFFFFFF),
  searchHitForeground: Color(0XFF000000),
);

class SshTerminalPage extends StatefulWidget {
  final String deviceName;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useJumpHost;
  final String? jumpHost;
  final int? jumpPort;
  final String? jumpUsername;
  final String? jumpPassword;
  final double initialFontSize;

  const SshTerminalPage({
    super.key,
    required this.deviceName,
    required this.host,
    this.port = 22,
    required this.username,
    required this.password,
    this.useJumpHost = false,
    this.jumpHost,
    this.jumpPort,
    this.jumpUsername,
    this.jumpPassword,
    this.initialFontSize = 13,
  });

  @override
  State<SshTerminalPage> createState() => _SshTerminalPageState();
}

class _SshTerminalPageState extends State<SshTerminalPage> {
  late final Terminal _terminal;
  final TerminalController _terminalController = TerminalController();
  final FocusNode _focusNode = FocusNode();

  SshShell? _shell;
  bool _isConnecting = true;
  bool _isConnected = false;
  String? _error;

  double _fontSize = 13;
  double _baseFontSize = 13;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize.clamp(8.0, 24.0);
    _baseFontSize = _fontSize;
    _terminal = Terminal(
      onOutput: _onTerminalOutput,
      onResize: _onTerminalResize,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _connect();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _shell?.close();
    _focusNode.dispose();
    _terminalController.dispose();
    super.dispose();
  }

  void _onTerminalOutput(String data) {
    if (_shell != null && _isConnected) {
      _shell!.write(data);
    }
  }

  void _onTerminalResize(
    int width,
    int height,
    int pixelWidth,
    int pixelHeight,
  ) {
    _shell?.session.resizeTerminal(width, height);
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _isConnected = false;
      _error = null;
    });

    try {
      SshShell shell;
      if (widget.useJumpHost) {
        shell = await SshService.openShellViaJump(
          jumpHost: widget.jumpHost!,
          jumpPort: widget.jumpPort ?? 22,
          jumpUsername: widget.jumpUsername!,
          jumpPassword: widget.jumpPassword!,
          targetHost: widget.host,
          targetPort: widget.port,
          targetUsername: widget.username,
          targetPassword: widget.password,
        );
      } else {
        shell = await SshService.openShell(
          host: widget.host,
          port: widget.port,
          username: widget.username,
          password: widget.password,
        );
      }

      shell.output.listen(
        (data) {
          final text = utf8.decode(data, allowMalformed: true);
          _terminal.write(text);
        },
        onError: (e) {
          setState(() {
            _terminal.write('\r\n\x1b[31m连接错误: $e\x1b[0m\r\n');
            _isConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _terminal.write('\r\n\x1b[31m连接已断开\x1b[0m\r\n');
            _isConnected = false;
          });
        },
      );

      setState(() {
        _shell = shell;
        _isConnecting = false;
        _isConnected = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _error = e.toString();
      });
    }
  }

  void _sendKey(String data) {
    if (_shell != null && _isConnected) {
      _shell!.write(data);
    }
  }

  void _sendByte(int byte) {
    if (_shell != null && _isConnected) {
      _shell!.writeBytes(Uint8List.fromList([byte]));
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseFontSize = _fontSize;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final scale = details.scale;
    if (scale == 0) return;
    final newSize = (_baseFontSize * scale).clamp(8.0, 24.0);
    if ((newSize - _fontSize).abs() > 0.5) {
      setState(() {
        _fontSize = newSize;
      });
    }
  }

  void _resetFontSize() {
    setState(() {
      _fontSize = widget.initialFontSize.clamp(8.0, 24.0);
      _baseFontSize = _fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isLandscape
          ? null
          : AppBar(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              titleSpacing: 0,
              title: Row(
                children: [
                  Icon(
                    _isConnected
                        ? Icons.circle
                        : _isConnecting
                        ? Icons.hourglass_empty
                        : Icons.error,
                    size: 12,
                    color: _isConnected
                        ? Colors.green
                        : _isConnecting
                        ? Colors.orange
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.deviceName),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: _resetFontSize,
                  tooltip: '重置字体大小',
                ),
                if (_isConnected)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined),
                    onPressed: () => _sendByte(0x03),
                    tooltip: '发送 Ctrl+C',
                  ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: () {
                    _shell?.close();
                    _connect();
                  },
                  tooltip: '重新连接',
                ),
              ],
            ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _isConnecting
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.greenAccent),
                          SizedBox(height: 16),
                          Text(
                            '正在连接...',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '连接失败',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _connect,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      child: TerminalView(
                        _terminal,
                        controller: _terminalController,
                        focusNode: _focusNode,
                        autoResize: true,
                        textStyle: TerminalStyle(
                          fontSize: _fontSize,
                          fontFamily: 'monospace',
                        ),
                        theme: _greenScreenTheme,
                        cursorType: TerminalCursorType.block,
                        alwaysShowCursor: true,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
            ),
            if (_isConnected && !isLandscape) _buildKeyBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyBar() {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildKey('Esc', () => _sendByte(0x1B)),
            _buildKey('Tab', () => _sendByte(0x09)),
            _buildKey('Ctrl', () => _sendByte(0x03), color: Colors.orange),
            _buildKey('↑', () => _sendKey('\x1b[A')),
            _buildKey('↓', () => _sendKey('\x1b[B')),
            _buildKey('←', () => _sendKey('\x1b[D')),
            _buildKey('→', () => _sendKey('\x1b[C')),
            _buildKey('PgUp', () => _sendKey('\x1b[5~')),
            _buildKey('PgDn', () => _sendKey('\x1b[6~')),
            _buildKey('Home', () => _sendKey('\x1b[H')),
            _buildKey('End', () => _sendKey('\x1b[F')),
            _buildKey('Del', () => _sendByte(0x7F)),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: color ?? Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
