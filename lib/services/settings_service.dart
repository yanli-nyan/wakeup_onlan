import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _ipAddressKey = 'ip_address';
  static const String _defaultIp = '192.168.1.100';
  static const String _macAddressKey = 'mac_address';
  static const String _defaultMac = '00:00:00:00:00:00';

  static const String _haPortKey = 'ha_port';
  static const int _defaultHaPort = 8123;
  static const String _haTokenKey = 'ha_token';
  static const String _defaultHaToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1ZjkwNWE5ZWY5MWE0NWIwYjc2ZjdmZmJiMDM1NDg3OSIsImlhdCI6MTc4NDY5OTM4MCwiZXhwIjoyMTAwMDU5MzgwfQ.lanOu2nVdWGaAMopyp7hMQR-7Ln8csvcZJNbU-8hguw';
  static const String _haSensorEntityKey = 'ha_sensor_entity';
  static const String _defaultHaSensorEntity = 'binary_sensor.192_168_1_100';
  static const String _haSwitchEntityKey = 'ha_switch_entity';
  static const String _defaultHaSwitchEntity = 'switch.desktop_pc';
  static const String _haSocketEntityKey = 'ha_socket_entity';
  static const String _defaultHaSocketEntity = 'switch.yutai_socn1_0c36_switch';

  static const String _tvLocalIpKey = 'tv_local_ip';
  static const String _defaultTvLocalIp = '192.168.1.4';
  static const String _tvTailscaleIpKey = 'tv_tailscale_ip';
  static const String _defaultTvTailscaleIp = '100.117.222.75';
  static const String _tvUserKey = 'tv_user';
  static const String _defaultTvUser = 'yanli';
  static const String _tvPassKey = 'tv_pass';
  static const String _defaultTvPass = '123';

  static const String _piIpKey = 'pi_ip';
  static const String _defaultPiIp = '192.168.1.2';
  static const String _piUserKey = 'pi_user';
  static const String _defaultPiUser = 'pi';
  static const String _piPassKey = 'pi_pass';
  static const String _defaultPiPass = '123';

  static const String _zeroIpKey = 'zero_ip';
  static const String _defaultZeroIp = '192.168.1.3';
  static const String _zeroUserKey = 'zero_user';
  static const String _defaultZeroUser = 'zero';
  static const String _zeroPassKey = 'zero_pass';
  static const String _defaultZeroPass = '123';

  static const String _useExternalSshAppKey = 'use_external_ssh_app';
  static const bool _defaultUseExternalSshApp = false;

  static const String _terminalFontSizeKey = 'terminal_font_size';
  static const double _defaultTerminalFontSize = 13.0;

  String _ipAddress = _defaultIp;
  String _macAddress = _defaultMac;
  int _haPort = _defaultHaPort;
  String _haToken = _defaultHaToken;
  String _haSensorEntity = _defaultHaSensorEntity;
  String _haSwitchEntity = _defaultHaSwitchEntity;
  String _haSocketEntity = _defaultHaSocketEntity;

  String _tvLocalIp = _defaultTvLocalIp;
  String _tvTailscaleIp = _defaultTvTailscaleIp;
  String _tvUser = _defaultTvUser;
  String _tvPass = _defaultTvPass;
  String _piIp = _defaultPiIp;
  String _piUser = _defaultPiUser;
  String _piPass = _defaultPiPass;
  String _zeroIp = _defaultZeroIp;
  String _zeroUser = _defaultZeroUser;
  String _zeroPass = _defaultZeroPass;
  bool _useExternalSshApp = _defaultUseExternalSshApp;
  double _terminalFontSize = _defaultTerminalFontSize;

  SharedPreferences? _prefs;

  String get ipAddress => _ipAddress;
  String get macAddress => _macAddress;

  int get haPort => _haPort;
  String get haLocalUrl => 'http://$_tvLocalIp:$_haPort';
  String get haTailscaleUrl => 'http://$_tvTailscaleIp:$_haPort';
  String get haToken => _haToken;
  String get haSensorEntity => _haSensorEntity;
  String get haSwitchEntity => _haSwitchEntity;
  String get haSocketEntity => _haSocketEntity;

  String get tvLocalIp => _tvLocalIp;
  String get tvTailscaleIp => _tvTailscaleIp;
  String get tvUser => _tvUser;
  String get tvPass => _tvPass;
  String get piIp => _piIp;
  String get piUser => _piUser;
  String get piPass => _piPass;
  String get zeroIp => _zeroIp;
  String get zeroUser => _zeroUser;
  String get zeroPass => _zeroPass;
  bool get useExternalSshApp => _useExternalSshApp;
  double get terminalFontSize => _terminalFontSize;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _ipAddress = _prefs?.getString(_ipAddressKey) ?? _defaultIp;
    _macAddress = _prefs?.getString(_macAddressKey) ?? _defaultMac;
    _haPort = _prefs?.getInt(_haPortKey) ?? _defaultHaPort;
    _haToken = _prefs?.getString(_haTokenKey) ?? _defaultHaToken;
    _haSensorEntity =
        _prefs?.getString(_haSensorEntityKey) ?? _defaultHaSensorEntity;
    _haSwitchEntity =
        _prefs?.getString(_haSwitchEntityKey) ?? _defaultHaSwitchEntity;
    _haSocketEntity =
        _prefs?.getString(_haSocketEntityKey) ?? _defaultHaSocketEntity;

    _tvLocalIp = _prefs?.getString(_tvLocalIpKey) ?? _defaultTvLocalIp;
    _tvTailscaleIp =
        _prefs?.getString(_tvTailscaleIpKey) ?? _defaultTvTailscaleIp;
    _tvUser = _prefs?.getString(_tvUserKey) ?? _defaultTvUser;
    _tvPass = _prefs?.getString(_tvPassKey) ?? _defaultTvPass;
    _piIp = _prefs?.getString(_piIpKey) ?? _defaultPiIp;
    _piUser = _prefs?.getString(_piUserKey) ?? _defaultPiUser;
    _piPass = _prefs?.getString(_piPassKey) ?? _defaultPiPass;
    _zeroIp = _prefs?.getString(_zeroIpKey) ?? _defaultZeroIp;
    _zeroUser = _prefs?.getString(_zeroUserKey) ?? _defaultZeroUser;
    _zeroPass = _prefs?.getString(_zeroPassKey) ?? _defaultZeroPass;
    _useExternalSshApp =
        _prefs?.getBool(_useExternalSshAppKey) ?? _defaultUseExternalSshApp;
    _terminalFontSize =
        _prefs?.getDouble(_terminalFontSizeKey) ?? _defaultTerminalFontSize;

    notifyListeners();
  }

  Future<void> setIpAddress(String ip) async {
    _ipAddress = ip;
    notifyListeners();
    await _prefs?.setString(_ipAddressKey, ip);
  }

  Future<void> setMacAddress(String mac) async {
    _macAddress = mac;
    notifyListeners();
    await _prefs?.setString(_macAddressKey, mac);
  }

  Future<void> setHaPort(int port) async {
    _haPort = port;
    notifyListeners();
    await _prefs?.setInt(_haPortKey, port);
  }

  Future<void> setHaToken(String token) async {
    _haToken = token;
    notifyListeners();
    await _prefs?.setString(_haTokenKey, token);
  }

  Future<void> setHaSensorEntity(String entity) async {
    _haSensorEntity = entity;
    notifyListeners();
    await _prefs?.setString(_haSensorEntityKey, entity);
  }

  Future<void> setHaSwitchEntity(String entity) async {
    _haSwitchEntity = entity;
    notifyListeners();
    await _prefs?.setString(_haSwitchEntityKey, entity);
  }

  Future<void> setHaSocketEntity(String entity) async {
    _haSocketEntity = entity;
    notifyListeners();
    await _prefs?.setString(_haSocketEntityKey, entity);
  }

  Future<void> setTvLocalIp(String ip) async {
    _tvLocalIp = ip;
    notifyListeners();
    await _prefs?.setString(_tvLocalIpKey, ip);
  }

  Future<void> setTvTailscaleIp(String ip) async {
    _tvTailscaleIp = ip;
    notifyListeners();
    await _prefs?.setString(_tvTailscaleIpKey, ip);
  }

  Future<void> setTvUser(String user) async {
    _tvUser = user;
    notifyListeners();
    await _prefs?.setString(_tvUserKey, user);
  }

  Future<void> setTvPass(String pass) async {
    _tvPass = pass;
    notifyListeners();
    await _prefs?.setString(_tvPassKey, pass);
  }

  Future<void> setPiIp(String ip) async {
    _piIp = ip;
    notifyListeners();
    await _prefs?.setString(_piIpKey, ip);
  }

  Future<void> setPiUser(String user) async {
    _piUser = user;
    notifyListeners();
    await _prefs?.setString(_piUserKey, user);
  }

  Future<void> setPiPass(String pass) async {
    _piPass = pass;
    notifyListeners();
    await _prefs?.setString(_piPassKey, pass);
  }

  Future<void> setZeroIp(String ip) async {
    _zeroIp = ip;
    notifyListeners();
    await _prefs?.setString(_zeroIpKey, ip);
  }

  Future<void> setZeroUser(String user) async {
    _zeroUser = user;
    notifyListeners();
    await _prefs?.setString(_zeroUserKey, user);
  }

  Future<void> setZeroPass(String pass) async {
    _zeroPass = pass;
    notifyListeners();
    await _prefs?.setString(_zeroPassKey, pass);
  }

  Future<void> setUseExternalSshApp(bool value) async {
    _useExternalSshApp = value;
    notifyListeners();
    await _prefs?.setBool(_useExternalSshAppKey, value);
  }

  Future<void> setTerminalFontSize(double size) async {
    _terminalFontSize = size.clamp(8.0, 24.0);
    notifyListeners();
    await _prefs?.setDouble(_terminalFontSizeKey, _terminalFontSize);
  }
}
