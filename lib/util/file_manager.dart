import 'dart:convert';
import 'dart:io';

import 'package:hosts/model/simple_host_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileManager {
  // 私有构造函数
  FileManager._internal() {
    _initializeDirectory();
  }

  static final systemHostFilePath = p.joinAll(Platform.isWindows
      ? ["C:", "Windows", "System32", "drivers", "etc", "hosts"]
      : ["/", "etc", "hosts"]);

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

  Future<String> getHostsFilePath(String fileId) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    return p.joinAll([_cachedDirectory!.path, fileId, 'hosts']);
  }

  // 创建文件夹
  Future<void> createHosts(String fileId) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileId.isEmpty) return;

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileId); // 只保留文件名，不允许路径
    final filePath = p.join(_cachedDirectory!.path, safeFileName);
    final directory = await Directory(filePath).create(recursive: true);
    await Directory(p.join(directory.path, "history")).create(recursive: true);
    await File(p.join(directory.path, "hosts")).create();
  }

  // 写入文件
  Future<File> writeFile(String pathName, String fileId,
      [String content = ""]) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    final directory = Directory(p.join(_cachedDirectory!.path, pathName));

    // 检查目录是否存在，如果不存在则创建
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileId); // 只保留文件名，不允许路径
    final filePath = p.join(directory.path, safeFileName);
    return await File(filePath).writeAsString(content);
  }

  // 读取文件的方法
  Future<String> readFile(String pathName, String fileId) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    final directory = Directory(p.join(_cachedDirectory!.path, pathName));

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileId); // 只保留文件名，不允许路径
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
      recursiveDelete(Directory(p.join(_cachedDirectory!.path, pathName)));
    }
  }

  void recursiveDelete(Directory dir) {
    if (!dir.existsSync()) {
      print("Directory does not exist: ${dir.path}");
      return;
    }

    List<FileSystemEntity> entities = dir.listSync();

    for (var entity in entities) {
      if (entity is File) {
        try {
          entity.deleteSync();
        } catch (e) {
          print("Error deleting file: ${entity.path} - ${e.toString()}");
        }
      } else if (entity is Directory) {
        recursiveDelete(entity);
      }
    }

    try {
      dir.deleteSync(recursive: true);
      print("Deleted folder: ${dir.path}");
    } catch (e) {
      print("Error deleting folder: ${dir.path} - ${e.toString()}");
    }
  }

  Future<List<SimpleHostFileHistory>> getHistory(String fileId) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileId.isEmpty) return [];
    Directory historyDirectory =
        Directory(p.joinAll([_cachedDirectory!.path, fileId, "history"]));
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

  void saveHistory(String fileId, String content) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileId.isEmpty) return;

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileId); // 只保留文件名，不允许路径
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

  void deleteFile(String path) {
    File(path).deleteSync();
  }

  String readHistoryFile(String path) {
    File file = File(path);
    if (!file.existsSync()) {
      return "";
    }
    return file.readAsStringSync();
  }

  // 比较两个文件是否相同
  Future<bool> areFilesEqual(String fileId) async {
    final file1 = File(await getHostsFilePath(fileId));
    final file2 = File(systemHostFilePath);

    // 检查文件是否存在
    if (!(await file1.exists()) || !(await file2.exists())) {
      return false;
    }

    // 读取文件内容
    final content1 = (await file1.readAsString())
        .replaceAll("\n", "")
        .replaceAll(" ", "")
        .replaceAll("	", "");
    final content2 = (await file2.readAsString())
        .replaceAll("\n", "")
        .replaceAll(" ", "")
        .replaceAll("	", "");
    // 比较内容
    return content1 == content2;
  }

  Future<String> writeFileWithAdminPrivileges(
      String cacheFilePath, String systemHostFilePath) async {
    String result = "";

    // TODO Windows Mac
    if (Platform.isLinux) {
      final Process process = await Process.start(
        "pkexec",
        ["cp", cacheFilePath, systemHostFilePath],
        mode: ProcessStartMode.normal,
      );

      // 处理标准输出
      process.stdout.transform(utf8.decoder).listen((data) {
        print('Output: $data');
        result = data;
      });

      // 处理标准错误
      String errorMessage = "";
      process.stderr.transform(utf8.decoder).listen((data) {
        errorMessage = data;
      });

      // 等待进程结束
      int exitCode = await process.exitCode;

      // 检查退出代码，如果非零则抛出异常
      if (errorMessage.isNotEmpty) {
        throw Exception(errorMessage);
      }
    }

    return result;
  }
}
