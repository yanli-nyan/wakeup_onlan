import 'dart:async';
import 'package:flutter/material.dart';
import 'pages/settings_page.dart';
import 'pages/ssh_terminal_page.dart';
import 'services/network_service.dart';
import 'services/settings_service.dart';
import 'services/app_launcher_service.dart';
import 'services/home_assistant_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wake On LAN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum PcStatus { online, offline, checking, waking, noNetwork }

class _HomePageState extends State<HomePage> {
  final SettingsService _settingsService = SettingsService();

  PcStatus _status = PcStatus.checking;
  bool _isInitialized = false;
  bool _isOnLocal = false;
  bool _isOnTailscale = false;

  HomeAssistantService? _haService;
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initSettings() async {
    await _settingsService.init();
    setState(() {
      _isInitialized = true;
    });
    _startAutoRefresh();
    _checkPcStatus();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (_status != PcStatus.waking) {
        _checkPcStatus(silent: true);
      }
    });
  }

  Future<void> _checkNetworkStatus() async {
    final onLocal = await NetworkService.isOnLocalNetwork();
    final onTailscale = await NetworkService.isOnTailscaleNetwork();
    if (mounted) {
      setState(() {
        _isOnLocal = onLocal;
        _isOnTailscale = onTailscale;
      });
    }
  }

  String _getHaBaseUrl() {
    if (_isOnLocal) {
      return _settingsService.haLocalUrl;
    } else if (_isOnTailscale) {
      return _settingsService.haTailscaleUrl;
    }
    return _settingsService.haLocalUrl;
  }

  Future<void> _checkPcStatus({bool silent = false}) async {
    if (!silent && _status == PcStatus.checking) return;
    if (!silent) {
      setState(() {
        _status = PcStatus.checking;
      });
    }

    await _checkNetworkStatus();

    bool online = false;

    if (_isOnLocal || _isOnTailscale) {
      _haService = HomeAssistantService(
        baseUrl: _getHaBaseUrl(),
        token: _settingsService.haToken,
      );
      final state = await _haService?.getEntityState(
        _settingsService.haSensorEntity,
      );
      online = state == 'on';
    } else {
      online = false;
    }

    if (mounted) {
      setState(() {
        if (online) {
          _status = PcStatus.online;
        } else if (_isOnLocal || _isOnTailscale) {
          _status = PcStatus.offline;
        } else {
          _status = PcStatus.noNetwork;
        }
      });
    }
  }

  bool _canWake() {
    return _isOnLocal || _isOnTailscale;
  }

  Future<void> _onCircleButtonTap() async {
    if (_status == PcStatus.online ||
        _status == PcStatus.checking ||
        _status == PcStatus.waking) {
      return;
    }

    await _checkNetworkStatus();

    if (_canWake()) {
      setState(() {
        _status = PcStatus.waking;
      });
      bool wakeOk = false;
      bool socketOk = false;
      try {
        _haService = HomeAssistantService(
          baseUrl: _getHaBaseUrl(),
          token: _settingsService.haToken,
        );
        // 1. 先打开裕泰供电插座
        socketOk =
            await _haService?.turnOnSwitch(_settingsService.haSocketEntity) ??
            false;
        // 延时500ms，等插座上电稳定
        await Future.delayed(const Duration(milliseconds: 500));
        // 2. 再触发WOL虚拟开关，HA自动化发送WOL魔术包
        wakeOk =
            await _haService?.turnOnSwitch(_settingsService.haSwitchEntity) ??
            false;

        if (mounted) {
          if (socketOk && wakeOk) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('已打开插座 + 发送WOL唤醒指令')));
          } else if (socketOk) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('插座已上电，WOL指令发送失败')));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('插座打开失败')));
          }
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('唤醒流程异常')));
        }
      }
      await Future.delayed(const Duration(seconds: 10));
      _checkPcStatus();
    } else {
      AppLauncherService.launchTailscale();
    }
  }

  Color _getButtonColor() {
    switch (_status) {
      case PcStatus.online:
        return Colors.blue;
      case PcStatus.offline:
        return Colors.orange;
      case PcStatus.checking:
        return Colors.grey;
      case PcStatus.waking:
        return Colors.amber;
      case PcStatus.noNetwork:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case PcStatus.online:
        return 'PC在线';
      case PcStatus.offline:
        if (_isOnLocal) {
          return 'PC离线，点击唤醒（局域网）';
        }
        if (_isOnTailscale) {
          return 'PC离线，点击唤醒（HA）';
        }
        return 'PC离线';
      case PcStatus.checking:
        return '检测中...';
      case PcStatus.waking:
        return '正在唤醒，请稍候...';
      case PcStatus.noNetwork:
        return 'PC离线，点击启动Tailscale';
    }
  }

  Color? _getStatusTextColor() {
    switch (_status) {
      case PcStatus.online:
        return Colors.blue;
      case PcStatus.offline:
        return Colors.orange;
      case PcStatus.checking:
        return Colors.grey[600];
      case PcStatus.waking:
        return Colors.amber;
      case PcStatus.noNetwork:
        return Colors.grey[600];
    }
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(settingsService: _settingsService),
      ),
    );
    _checkPcStatus();
  }

  void _openSshTerminal(String device) {
    if (_settingsService.useExternalSshApp) {
      AppLauncherService.launchConnectBot();
      return;
    }

    if (!_isOnLocal && !_isOnTailscale) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先连接网络')));
      return;
    }

    final tvHost = _isOnLocal
        ? _settingsService.tvLocalIp
        : _settingsService.tvTailscaleIp;

    String targetHost;
    String targetUser;
    String targetPass;
    bool useJump = false;

    if (device == 'tv') {
      targetHost = tvHost;
      targetUser = _settingsService.tvUser;
      targetPass = _settingsService.tvPass;
    } else if (device == 'pi') {
      targetHost = _settingsService.piIp;
      targetUser = _settingsService.piUser;
      targetPass = _settingsService.piPass;
      useJump = true;
    } else if (device == 'zero') {
      targetHost = _settingsService.zeroIp;
      targetUser = _settingsService.zeroUser;
      targetPass = _settingsService.zeroPass;
      useJump = true;
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SshTerminalPage(
          deviceName: device.toUpperCase(),
          host: targetHost,
          port: 22,
          username: targetUser,
          password: targetPass,
          useJumpHost: useJump,
          jumpHost: useJump ? tvHost : null,
          jumpPort: 22,
          jumpUsername: useJump ? _settingsService.tvUser : null,
          jumpPassword: useJump ? _settingsService.tvPass : null,
          initialFontSize: _settingsService.terminalFontSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wake On LAN'),
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _checkPcStatus(silent: false),
          tooltip: '刷新',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap:
                  _status == PcStatus.online ||
                      _status == PcStatus.checking ||
                      _status == PcStatus.waking
                  ? null
                  : _onCircleButtonTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _getButtonColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getButtonColor().withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _status == PcStatus.waking
                    ? const Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.power_settings_new,
                        size: 80,
                        color: Colors.white,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusTextColor(),
                  ) ??
                  const TextStyle(),
              child: Text(_getStatusText()),
            ),
            if (_status == PcStatus.checking)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSquareButton(
              icon: Icons.tv,
              label: 'TV',
              onTap: () => _openSshTerminal('tv'),
            ),
            _buildSquareButton(
              icon: Icons.memory,
              label: 'Pi',
              onTap: () => _openSshTerminal('pi'),
            ),
            _buildSquareButton(
              icon: Icons.developer_board,
              label: 'Zero',
              onTap: () => _openSshTerminal('zero'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Container(
          width: 90,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
