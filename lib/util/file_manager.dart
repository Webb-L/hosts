import 'dart:io';

import 'package:hosts/model/simple_host_file.dart';
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
  Future<void> deleteFiles(List<String> fileNames) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    for (var pathName in fileNames) {
      deleteRecursively(Directory(p.join(_cachedDirectory!.path, pathName)));
    }
  }

  void deleteRecursively(Directory dir) {
    // 获取目录中的所有文件和子目录
    var entities = dir.listSync();

    for (var entity in entities) {
      if (entity is File) {
        // 删除文件
        entity.deleteSync();
      } else if (entity is Directory) {
        // 递归删除子目录
        deleteRecursively(entity);
        // 删除目录本身
        entity.deleteSync();
      }
    }

    dir.delete();
  }

  // TODO 保存后不会更新数据。
  Future<List<SimpleHostFileHistory>> getHistory(String fileName) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileName.isEmpty) return [];
    Directory historyDirectory =
        Directory(p.joinAll([_cachedDirectory!.path, fileName, "history"]));
    if (!historyDirectory.existsSync()) {
      return [];
    }
    return historyDirectory
        .listSync()
        .map(
          (item) => SimpleHostFileHistory(
            fileName: item.uri.pathSegments.last,
            path: item.path,
          ),
        )
        .toList();
  }

  void saveHistory(String fileName, String content) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileName.isEmpty) return;

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileName); // 只保留文件名，不允许路径
    final filePath = p.join(_cachedDirectory!.path, safeFileName);
    Directory rootDirectory = Directory(filePath);
    if (!rootDirectory.existsSync()) {
      rootDirectory.create(recursive: true);
    }
    Directory historyDirectory =
        Directory(p.join(rootDirectory.path, "history"));
    if (!historyDirectory.existsSync()) {
      historyDirectory.create(recursive: true);
    }
    File(
      p.join(historyDirectory.path,
          DateTime.now().millisecondsSinceEpoch.toString()),
    ).writeAsString(content);
  }
}
