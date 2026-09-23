import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsPage({super.key, required this.settingsService});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _ipController;
  late TextEditingController _macController;
  late TextEditingController _haPortController;
  late TextEditingController _haTokenController;
  late TextEditingController _haSensorController;
  late TextEditingController _haSwitchController;

  late TextEditingController _tvLocalIpController;
  late TextEditingController _tvTailscaleIpController;
  late TextEditingController _tvUserController;
  late TextEditingController _tvPassController;
  late TextEditingController _piIpController;
  late TextEditingController _piUserController;
  late TextEditingController _piPassController;
  late TextEditingController _zeroIpController;
  late TextEditingController _zeroUserController;
  late TextEditingController _zeroPassController;
  bool _haExpanded = false;
  bool _sshExpanded = false;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(
      text: widget.settingsService.ipAddress,
    );
    _macController = TextEditingController(
      text: widget.settingsService.macAddress,
    );
    _haPortController = TextEditingController(
      text: widget.settingsService.haPort.toString(),
    );
    _haTokenController = TextEditingController(
      text: widget.settingsService.haToken,
    );
    _haSensorController = TextEditingController(
      text: widget.settingsService.haSensorEntity,
    );
    _haSwitchController = TextEditingController(
      text: widget.settingsService.haSwitchEntity,
    );

    _tvLocalIpController = TextEditingController(
      text: widget.settingsService.tvLocalIp,
    );
    _tvTailscaleIpController = TextEditingController(
      text: widget.settingsService.tvTailscaleIp,
    );
    _tvUserController = TextEditingController(
      text: widget.settingsService.tvUser,
    );
    _tvPassController = TextEditingController(
      text: widget.settingsService.tvPass,
    );
    _piIpController = TextEditingController(text: widget.settingsService.piIp);
    _piUserController = TextEditingController(
      text: widget.settingsService.piUser,
    );
    _piPassController = TextEditingController(
      text: widget.settingsService.piPass,
    );
    _zeroIpController = TextEditingController(
      text: widget.settingsService.zeroIp,
    );
    _zeroUserController = TextEditingController(
      text: widget.settingsService.zeroUser,
    );
    _zeroPassController = TextEditingController(
      text: widget.settingsService.zeroPass,
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _macController.dispose();
    _haPortController.dispose();
    _haTokenController.dispose();
    _haSensorController.dispose();
    _haSwitchController.dispose();

    _tvLocalIpController.dispose();
    _tvTailscaleIpController.dispose();
    _tvUserController.dispose();
    _tvPassController.dispose();
    _piIpController.dispose();
    _piUserController.dispose();
    _piPassController.dispose();
    _zeroIpController.dispose();
    _zeroUserController.dispose();
    _zeroPassController.dispose();
    super.dispose();
  }

  void _saveIp() {
    final ip = _ipController.text.trim();
    if (ip.isNotEmpty) {
      widget.settingsService.setIpAddress(ip);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('IP地址已保存')));
    }
  }

  void _saveMac() {
    final mac = _macController.text.trim();
    if (mac.isNotEmpty) {
      widget.settingsService.setMacAddress(mac);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MAC地址已保存')));
    }
  }

  void _saveHaPort() {
    final port = int.tryParse(_haPortController.text.trim());
    if (port != null && port > 0 && port < 65536) {
      widget.settingsService.setHaPort(port);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('HA端口已保存')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的端口号(1-65535)')));
    }
  }

  void _saveHaToken() {
    final token = _haTokenController.text.trim();
    if (token.isNotEmpty) {
      widget.settingsService.setHaToken(token);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('HA密钥已保存')));
    }
  }

  void _saveHaSensor() {
    final entity = _haSensorController.text.trim();
    if (entity.isNotEmpty) {
      widget.settingsService.setHaSensorEntity(entity);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('传感器实体已保存')));
    }
  }

  void _saveHaSwitch() {
    final entity = _haSwitchController.text.trim();
    if (entity.isNotEmpty) {
      widget.settingsService.setHaSwitchEntity(entity);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('开关实体已保存')));
    }
  }

  void _saveTvLocalIp() {
    final v = _tvLocalIpController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setTvLocalIp(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('TV局域网IP已保存')));
    }
  }

  void _saveTvTailscaleIp() {
    final v = _tvTailscaleIpController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setTvTailscaleIp(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('TV Tailscale IP已保存')));
    }
  }

  void _saveTvUser() {
    final v = _tvUserController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setTvUser(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('TV用户名已保存')));
    }
  }

  void _saveTvPass() {
    final v = _tvPassController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setTvPass(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('TV密码已保存')));
    }
  }

  void _savePiIp() {
    final v = _piIpController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setPiIp(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pi IP已保存')));
    }
  }

  void _savePiUser() {
    final v = _piUserController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setPiUser(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pi用户名已保存')));
    }
  }

  void _savePiPass() {
    final v = _piPassController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setPiPass(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pi密码已保存')));
    }
  }

  void _saveZeroIp() {
    final v = _zeroIpController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setZeroIp(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zero IP已保存')));
    }
  }

  void _saveZeroUser() {
    final v = _zeroUserController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setZeroUser(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zero用户名已保存')));
    }
  }

  void _saveZeroPass() {
    final v = _zeroPassController.text.trim();
    if (v.isNotEmpty) {
      widget.settingsService.setZeroPass(v);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zero密码已保存')));
    }
  }

  Widget _buildTvSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tv, size: 20),
                const SizedBox(width: 8),
                Text(
                  'TV (Armbian)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tvLocalIpController,
              decoration: InputDecoration(
                labelText: '局域网IP地址',
                prefixIcon: const Icon(Icons.computer, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: _saveTvLocalIp,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _saveTvLocalIp(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tvTailscaleIpController,
              decoration: InputDecoration(
                labelText: 'Tailscale IP地址',
                prefixIcon: const Icon(Icons.vpn_lock, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: _saveTvTailscaleIp,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _saveTvTailscaleIp(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tvUserController,
              decoration: InputDecoration(
                labelText: '用户名',
                prefixIcon: const Icon(Icons.person, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: _saveTvUser,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _saveTvUser(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tvPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.key, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: _saveTvPass,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _saveTvPass(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSshDeviceSection({
    required String title,
    required TextEditingController ipController,
    required TextEditingController userController,
    required TextEditingController passController,
    required VoidCallback onSaveIp,
    required VoidCallback onSaveUser,
    required VoidCallback onSavePass,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'IP地址',
                prefixIcon: const Icon(Icons.computer, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: onSaveIp,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSaveIp(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: '用户名',
                prefixIcon: const Icon(Icons.person, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: onSaveUser,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSaveUser(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.key, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  onPressed: onSavePass,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSavePass(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '设备IP地址',
                hintText: '例如: 192.168.1.100',
                prefixIcon: const Icon(Icons.computer),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveIp,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveIp(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _macController,
              decoration: InputDecoration(
                labelText: '设备MAC地址',
                hintText: '例如: 00:1A:2B:3C:4D:5E',
                prefixIcon: const Icon(Icons.settings_ethernet),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveMac,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveMac(),
            ),
          ),
          const Divider(),
          ExpansionTile(
            title: const Text('Home Assistant'),
            subtitle: const Text('通过HA检测和唤醒电脑'),
            leading: const Icon(Icons.home),
            initiallyExpanded: _haExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _haExpanded = expanded;
              });
            },
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text('HA 地址自动生成'),
                subtitle: Text('局域网地址和 Tailscale 地址由「SSH 设备 - TV」的 IP 自动拼接'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _haPortController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'HA 端口',
                    hintText: '例如: 8123',
                    prefixIcon: const Icon(Icons.settings_ethernet),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveHaPort,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _saveHaPort(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _haTokenController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'HA密钥 (Token)',
                    hintText: 'Long-Lived Access Token',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveHaToken,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _saveHaToken(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _haSensorController,
                  decoration: InputDecoration(
                    labelText: '在线检测实体',
                    hintText: '例如: binary_sensor.192_168_1_100',
                    prefixIcon: const Icon(Icons.sensors),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveHaSensor,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _saveHaSensor(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _haSwitchController,
                  decoration: InputDecoration(
                    labelText: '唤醒开关实体',
                    hintText: '例如: switch.desktop_pc',
                    prefixIcon: const Icon(Icons.power),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveHaSwitch,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _saveHaSwitch(),
                ),
              ),
            ],
          ),
          const Divider(),
          ExpansionTile(
            title: const Text('SSH 设备'),
            subtitle: const Text('通过SSH连接管理设备'),
            leading: const Icon(Icons.terminal),
            initiallyExpanded: _sshExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _sshExpanded = expanded;
              });
            },
            children: [
              _buildTvSection(),
              _buildSshDeviceSection(
                title: 'Pi',
                ipController: _piIpController,
                userController: _piUserController,
                passController: _piPassController,
                onSaveIp: _savePiIp,
                onSaveUser: _savePiUser,
                onSavePass: _savePiPass,
                icon: Icons.memory,
              ),
              _buildSshDeviceSection(
                title: 'Zero',
                ipController: _zeroIpController,
                userController: _zeroUserController,
                passController: _zeroPassController,
                onSaveIp: _saveZeroIp,
                onSaveUser: _saveZeroUser,
                onSavePass: _saveZeroPass,
                icon: Icons.developer_board,
              ),
              const Divider(height: 16),
              SwitchListTile(
                title: const Text('使用外部SSH应用'),
                subtitle: const Text('开启后点击按钮直接打开 ConnectBot'),
                secondary: const Icon(Icons.open_in_new),
                value: widget.settingsService.useExternalSshApp,
                onChanged: (value) {
                  widget.settingsService.setUseExternalSshApp(value);
                  setState(() {});
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('终端字体大小'),
                subtitle: Text(
                  '${widget.settingsService.terminalFontSize.toStringAsFixed(0)} sp',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Aa',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Expanded(
                      child: Slider(
                        value: widget.settingsService.terminalFontSize,
                        min: 8,
                        max: 24,
                        divisions: 16,
                        label:
                            '${widget.settingsService.terminalFontSize.toStringAsFixed(0)} sp',
                        onChanged: (value) {
                          widget.settingsService.setTerminalFontSize(value);
                          setState(() {});
                        },
                      ),
                    ),
                    const Text(
                      'Aa',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

          const Divider(),
          ListTile(
            title: const Text('关于'),
            subtitle: const Text('版本 1.1.0'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
