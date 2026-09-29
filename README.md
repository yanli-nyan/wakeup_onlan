# Wake On LAN

[中文](#中文) | [English](#english)

---

## 中文

一个面向 Android 的 Flutter 局域网设备控制应用。它通过 **Home Assistant** 检测桌面电脑状态，并按「开启智能插座 → 等待 500 ms → 触发 WOL 开关」的顺序唤醒电脑；同时提供 TV、Pi 和 Zero 设备的 SSH 终端入口。

### 功能

- 每 5 秒通过 Home Assistant 的二进制传感器检测 PC 是否在线，也可手动刷新。
- 用一个大号电源按钮唤醒离线 PC：先打开配置的智能插座，再触发 Home Assistant 中负责发送 WOL 魔术包的开关或自动化。
- 自动识别当前连接：局域网仅识别 `192.168.1.x`，Tailscale 识别 `100.64.0.0/10` 地址。
- 未连接上述网络时，点击唤醒按钮会启动 Tailscale；若未安装，则跳转 Google Play。
- 内置绿色主题 SSH 终端，支持屏幕旋转、双指缩放字体、常用快捷键和重连。
- TV 使用直接 SSH 连接；Pi 与 Zero 通过 TV 建立 SSH 跳板连接。
- 可改用外部 ConnectBot 作为 SSH 客户端；未安装时会跳转 Google Play。
- 通过 `shared_preferences` 保存 Home Assistant、SSH、终端字号等设置。

### 环境要求

- Flutter SDK（项目声明 Dart SDK `^3.11.5`）
- Android 设备或模拟器
- 可访问的 Home Assistant 实例
- 已在 Home Assistant 中配置用于表示 PC 在线状态的实体、用于发送 WOL 的 `switch` 实体或等效自动化，以及（可选）为 PC 供电的智能插座 `switch` 实体。
- 如需从非局域网访问，Android 设备与 Home Assistant/TV 应加入同一 Tailscale 网络。

### 快速开始

```bash
git clone <repository-url>
cd wakeup_onlan
flutter pub get
flutter run
```

生成 Android 发布包：

```bash
flutter build apk --release
```

### 首次配置

打开应用右上角的“设置”，按你的环境填写以下内容：

| 分组 | 需要配置的内容 |
| --- | --- |
| 设备 | PC IP 和 MAC 地址（当前主要由 Home Assistant 执行状态检测和唤醒，仍建议保留正确值） |
| Home Assistant | 端口、Long-Lived Access Token、在线检测实体、WOL 开关实体 |
| SSH 设备 - TV | 局域网 IP、Tailscale IP、用户名、密码；Home Assistant 地址由此处 IP 与 HA 端口自动拼接 |
| SSH 设备 - Pi / Zero | 目标 IP、用户名、密码；连接会经过 TV 跳板 |
| 终端 | 内置终端字体大小，或启用 ConnectBot |

唤醒流程所用的“插座开关实体”也需正确配置。当前设置页未提供该字段的编辑入口；它由 `SettingsService` 中的默认值或既有本地偏好设置提供。如需用于其他环境，请在代码中调整默认值，或补充相应的设置界面。

### 使用说明

1. 确认手机已连接到 `192.168.1.x` 局域网，或已连入 Tailscale。
2. 在主页确认 PC 状态：蓝色表示在线，橙色表示离线可唤醒，灰色表示未检测到可用网络。
3. PC 离线时，点击电源按钮。应用会调用 Home Assistant 先给插座上电，然后触发 WOL 开关；约 10 秒后再次检测状态。
4. 点击底部 **TV**、**Pi** 或 **Zero** 打开 SSH。Pi 和 Zero 会通过 TV 作为跳板主机；使用外部 SSH 应用时，按钮会直接打开 ConnectBot。

### 注意事项与安全性

- 这是针对固定家庭网络设计的应用；局域网识别目前硬编码为 `192.168.1.x`。使用其他网段时，需要修改 `lib/services/network_service.dart`。
- Home Assistant 地址固定拼接为 `http://<TV IP>:<HA 端口>`，当前未启用 HTTPS。若通过不受信任的网络访问，应改用 HTTPS 并妥善处理证书。
- Home Assistant Token 和 SSH 密码会保存到设备的本地偏好设置中；请使用可信设备，并避免将实际凭据提交到版本库。
- 请在部署或公开项目之前，移除或轮换代码中可能存在的默认 Token、密码、IP 地址及实体 ID。
- 内置 SSH 登录目前使用用户名和密码；请仅连接你有授权管理的设备。

### 技术栈

- Flutter / Material 3
- `shared_preferences`：本地设置
- `dartssh2`：SSH 与跳板连接
- `xterm`：嵌入式终端
- Home Assistant REST API：状态查询和开关控制
- Android MethodChannel：启动 Tailscale、ConnectBot 或其 Google Play 页面

### 项目结构

```text
lib/
├── main.dart                         # 主页、状态轮询与唤醒流程
├── pages/
│   ├── settings_page.dart             # 配置页面
│   └── ssh_terminal_page.dart         # 内置 SSH 终端
└── services/
    ├── home_assistant_service.dart    # Home Assistant REST API
    ├── network_service.dart           # 网络识别与 WOL 数据包工具
    ├── settings_service.dart          # 本地设置持久化
    ├── ssh_service.dart               # SSH / 跳板连接
    └── app_launcher_service.dart      # 启动外部 Android 应用
```

---

## English

An Android-focused Flutter app for controlling devices on a home network. It checks a desktop PC's status through **Home Assistant** and wakes it in the sequence **power socket on → wait 500 ms → trigger the WOL switch**. It also provides SSH terminal shortcuts for TV, Pi, and Zero devices.

### Features

- Polls a Home Assistant binary sensor for PC status every five seconds, with manual refresh.
- Wakes an offline PC by turning on a configured smart socket and then triggering a Home Assistant switch or automation that sends the WOL magic packet.
- Detects the active connection automatically: LAN is currently limited to `192.168.1.x`; Tailscale uses `100.64.0.0/10` addresses.
- Opens Tailscale when neither supported network is detected; opens Google Play if Tailscale is not installed.
- Includes a green-screen SSH terminal with rotation, pinch-to-zoom text, shortcut keys, and reconnect support.
- Connects directly to TV over SSH; connects to Pi and Zero through TV as an SSH jump host.
- Can delegate SSH launching to ConnectBot, with a Google Play fallback.
- Persists Home Assistant, SSH, and terminal settings with `shared_preferences`.

### Requirements

- Flutter SDK (the project declares Dart SDK `^3.11.5`)
- An Android device or emulator
- A reachable Home Assistant instance
- Home Assistant entities for PC online status, a `switch` entity or equivalent automation that sends WOL, and optionally a smart-socket `switch` that powers the PC.
- For off-LAN use, the Android device and the Home Assistant/TV host should be on the same Tailscale network.

### Get started

```bash
git clone <repository-url>
cd wakeup_onlan
flutter pub get
flutter run
```

Build a release APK:

```bash
flutter build apk --release
```

### Initial configuration

Open **Settings** from the upper-right corner and enter values for your environment:

| Section | Configuration |
| --- | --- |
| Device | PC IP and MAC address. The current wake/status flow is primarily Home Assistant-based, but these values should still be accurate. |
| Home Assistant | Port, Long-Lived Access Token, online-status entity, and WOL switch entity. |
| SSH devices – TV | LAN IP, Tailscale IP, username, and password. The Home Assistant URL is composed from this IP and the HA port. |
| SSH devices – Pi / Zero | Target IP, username, and password. These sessions use TV as a jump host. |
| Terminal | Built-in terminal font size, or enable ConnectBot. |

The smart-socket entity used in the wake sequence must also be configured. The current settings screen has no field for it; its value comes from the `SettingsService` default or an existing local preference. For another environment, change the default in code or add a setting for it.

### Usage

1. Connect the phone to a `192.168.1.x` LAN or to Tailscale.
2. Check the PC status on the home screen: blue means online, orange means offline and wakeable, and gray means no supported network was detected.
3. When the PC is offline, tap the power button. The app powers the socket through Home Assistant, triggers the WOL switch, and checks the state again after about 10 seconds.
4. Tap **TV**, **Pi**, or **Zero** at the bottom to open SSH. Pi and Zero use TV as the jump host. When external SSH is enabled, the button opens ConnectBot instead.

### Notes and security

- The app is designed for a fixed home-network setup. LAN detection is currently hard-coded to `192.168.1.x`; adapt `lib/services/network_service.dart` for other subnets.
- Home Assistant URLs are formed as `http://<TV IP>:<HA port>` and HTTPS is not currently enabled. Use HTTPS and appropriate certificate handling for untrusted networks.
- Home Assistant tokens and SSH passwords are stored in local app preferences. Use a trusted device and never commit real credentials.
- Before deployment or publication, remove or rotate any default tokens, passwords, IP addresses, and entity IDs that may exist in the source.
- The built-in SSH client uses password authentication. Connect only to devices you are authorized to administer.

### Stack

- Flutter / Material 3
- `shared_preferences` for local settings
- `dartssh2` for SSH and jump-host connections
- `xterm` for the embedded terminal
- Home Assistant REST API for status and switch control
- Android MethodChannel for launching Tailscale, ConnectBot, or their Google Play pages

### Project layout

```text
lib/
├── main.dart                         # Home screen, polling, and wake flow
├── pages/
│   ├── settings_page.dart             # Settings UI
│   └── ssh_terminal_page.dart         # Embedded SSH terminal
└── services/
    ├── home_assistant_service.dart    # Home Assistant REST API
    ├── network_service.dart           # Network detection and WOL packet utility
    ├── settings_service.dart          # Local settings persistence
    ├── ssh_service.dart               # SSH / jump-host connections
    └── app_launcher_service.dart      # External Android app launcher
```
