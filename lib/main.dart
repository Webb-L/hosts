import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/home_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsManager settingsManager = SettingsManager();
  FileManager fileManager = FileManager();
  bool firstOpenApp = await settingsManager.getBool(settingKeyFirstOpenApp);
  if (!firstOpenApp) {
    const String fileName = "system";
    await fileManager.createHosts(fileName);
    await settingsManager.setList(settingKeyHostConfigs,
        [SimpleHostFile(fileName: fileName, remark: "默认")]);
    await settingsManager.setString(settingKeyUseHostFile, fileName);
    final List<String> systemHostFilePath = Platform.isWindows
        ? ["C:", "Windows", "System32", "drivers", "etc", "hosts"]
        : ["etc", "hosts"];
    File(p.joinAll(systemHostFilePath))
        .copy(await fileManager.getHostsFilePath(fileName));
    settingsManager.setBool(settingKeyFirstOpenApp, true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hosts Editor',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
