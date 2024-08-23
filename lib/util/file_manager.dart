import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileManager {
  // 私有构造函数
  FileManager._internal() {
    _initializeDirectory();
  }

  // 静态变量保存单例实例
  static final FileManager _instance = FileManager._internal();

  // 工厂构造函数返回单例实例
  factory FileManager() => _instance;

  // 缓存的应用支持目录
  Directory? _cachedDirectory;

  // 初始化缓存的应用支持目录
  Future<void> _initializeDirectory() async {
    _cachedDirectory = await getApplicationSupportDirectory();
  }

  Future<String> getHostsFilePath(String fileName) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    return p.joinAll([_cachedDirectory!.path, fileName, 'hosts']);
  }

  // 创建文件夹
  Future<void> createHosts(String fileName) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileName.isEmpty) return;

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileName); // 只保留文件名，不允许路径
    final filePath = p.join(_cachedDirectory!.path, safeFileName);
    final directory = await Directory(filePath).create(recursive: true);
    await Directory(p.join(directory.path, "history")).create(recursive: true);
    await File(p.join(directory.path, "hosts")).create();
  }

  // 写入文件
  Future<File> writeFile(String pathName, String fileName,
      [String content = ""]) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    final directory = Directory(p.join(_cachedDirectory!.path, pathName));

    // 检查目录是否存在，如果不存在则创建
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileName); // 只保留文件名，不允许路径
    final filePath = p.join(directory.path, safeFileName);
    return await File(filePath).writeAsString(content);
  }

  // 读取文件的方法
  Future<String> readFile(String pathName, String fileName) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    final directory = Directory(p.join(_cachedDirectory!.path, pathName));

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileName); // 只保留文件名，不允许路径
    final filePath = p.join(directory.path, safeFileName);
    final file = File(filePath);

    // 检查文件是否存在
    if (await file.exists()) {
      return await file.readAsString();
    } else {
      return '';
    }
  }

  // 删除文件
  Future<void> deleteFile(String fileName) async {
    try {
      if (_cachedDirectory == null) await _initializeDirectory();
      final file = File('${_cachedDirectory!.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
