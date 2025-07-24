import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:hosts/app.dart';
import 'package:hosts/host_observer.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const HostObserver();

  // 初始化后台运行配置
  await _initializeBackgroundService();

  final Iterable<String> files = args.where((path) => File(path).existsSync());
  if (files.isNotEmpty) {
    runApp(HostsApp(files.first));
  } else {
    runApp(HostsApp(""));
  }
}

Future<void> _initializeBackgroundService() async {
  // Web环境不支持后台服务
  if (kIsWeb) {
    return;
  }
  
  // 只在Android平台初始化后台服务
  if (!Platform.isAndroid) {
    return;
  }
  
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Hosts 编辑器",
    notificationText: "正在后台运行 hosts 服务",
    notificationImportance: AndroidNotificationImportance.normal,
    notificationIcon:
        AndroidResource(name: 'background_icon', defType: 'drawable'),
  );

  await FlutterBackground.initialize(androidConfig: androidConfig);
}
