import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hosts/home/view/home_page.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/global_settings.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/server/server_manager.dart';
import 'package:hosts/theme.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';

class HostsApp extends MaterialApp {
  final String filePath;

  HostsApp(this.filePath, {super.key})
      : super(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
          // locale: Locale("en"),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: MaterialTheme.lightScheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: MaterialTheme.darkScheme(),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: _platformSpecificWidget(filePath),
        );
}

Widget _platformSpecificWidget(String filePath) {
  if (filePath.isNotEmpty) {
    GlobalSettings().filePath = filePath;
  }
  if (GlobalSettings().filePath != null || kIsWeb) {
    return SimpleHomePage();
  } else {
    return FutureBuilder<void>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const HomePage();
        }
      },
    );
  }
}

Future<void> _initializeApp() async {
  SettingsManager settingsManager = SettingsManager();
  FileManager fileManager = FileManager();

  bool firstOpenApp = await settingsManager.getBool(settingKeyFirstOpenApp);
  if (!firstOpenApp) {
    const String fileName = "system";
    await fileManager.createHosts(fileName);
    await settingsManager.setList(settingKeyHostConfigs,
        [SimpleHostFile(fileName: fileName, remark: "")]);
    await settingsManager.setString(settingKeyUseHostFile, fileName);
    File(FileManager.systemHostFilePath)
        .copy(await fileManager.getHostsFilePath(fileName));
    settingsManager.setBool(settingKeyFirstOpenApp, true);
  }

  // 异步启动服务器，不阻塞应用初始化
  _startServerInBackground(settingsManager);
}

/// 在后台异步启动服务器，不阻塞应用初始化
void _startServerInBackground(SettingsManager settingsManager) {
  ServerManager serverManager = ServerManager();

  Future.microtask(() async {
    try {
      // 检查是否启用了自动启动服务器
      bool isAutoStartEnabled =
          await settingsManager.getBool(settingKeyAutoStartEnabled);
      if (isAutoStartEnabled) {
        // 获取保存的hosts文件列表
        List<dynamic> savedHostsList =
            await settingsManager.getList(settingKeyAutoStartHosts);

        if (savedHostsList.isNotEmpty) {
          // 将JSON数据转换为SimpleHostFile对象
          List<SimpleHostFile> autoStartHosts = savedHostsList
              .map((json) => SimpleHostFile.fromJson(json))
              .toList();

          // 启动服务器
          await serverManager.startServer(
            allowedHostFiles:
                autoStartHosts.map((host) => host.fileName).toList(),
          );

          print('自动启动服务器成功，共享${autoStartHosts.length}个hosts文件');
        } else {
          print('自动启动已启用，但没有找到保存的hosts文件列表');
        }
      }
    } catch (e) {
      print('自动启动服务器失败: $e');
    }
  });
}
