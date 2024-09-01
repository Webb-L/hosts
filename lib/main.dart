import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/home_page.dart';
import 'package:hosts/theme.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
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
      home: FutureBuilder<void>(
        future: initializeApp(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }

  Future<void> initializeApp(BuildContext context) async {
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
  }
}
