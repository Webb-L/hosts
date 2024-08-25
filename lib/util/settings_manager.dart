import 'dart:convert'; // 导入 JSON 编码和解码

import 'package:shared_preferences/shared_preferences.dart';

const String settingKeyFirstOpenApp = "FirstOpenApp";
const String settingKeyHostConfigs = "HostConfigs";
const String settingKeyUseHostFile = "UseHostFileKey";

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() => _instance;

  SettingsManager._internal();

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await _getPrefs();
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _getPrefs();
    return prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key)??false;
  }

  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  Future<void> setList(String key, List<dynamic> value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, json.encode(value));
  }

  Future<List<dynamic>> getList(String key) async {
    final prefs = await _getPrefs();
    return json.decode(prefs.getString(key) ?? "[]") ?? [];
  }
}
