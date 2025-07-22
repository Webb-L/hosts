import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/regexp_util.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// 导入hosts文件的数据模型
class ImportableHost {
  final String remark;
  final String fileName;
  final String folderPath;
  final bool hasContent;
  
  ImportableHost({
    required this.remark,
    required this.fileName,
    required this.folderPath,
    required this.hasContent,
  });
}

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

  static const MethodChannel _channel =
      MethodChannel('top.webb_l.hosts/system');

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

  Future<String> readAsString(String fileId) async {
    final path = await getHostsFilePath(fileId);
    return File(path).readAsString();
  }

  Future<List<String>> readAsLines(String fileId) async {
    final path = await getHostsFilePath(fileId);
    return await File(path).readAsLines();
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
    final historyList = historyDirectory
        .listSync()
        .map(
          (item) => SimpleHostFileHistory(
            fileName: item.uri.pathSegments.last,
            path: item.path,
          ),
        )
        .toList();
    
    // 按fileName倒序排序
    historyList.sort((a, b) => b.fileName.compareTo(a.fileName));
    
    return historyList;
  }

  Future<void> saveHistory(String fileId, String content) async {
    if (_cachedDirectory == null) await _initializeDirectory();
    if (fileId.isEmpty) return;

    // 规范化文件名，防止目录穿越
    final safeFileName = p.basename(fileId); // 只保留文件名，不允许路径
    final filePath = p.join(_cachedDirectory!.path, safeFileName);
    Directory rootDirectory = Directory(filePath);
    if (!(await rootDirectory.exists())) {
      rootDirectory.create(recursive: true);
    }
    Directory historyDirectory =
        Directory(p.join(rootDirectory.path, "history"));
    if (!(await historyDirectory.exists())) {
      historyDirectory.create(recursive: true);
    }
    final File file = File(
      p.join(historyDirectory.path,
          DateTime.now().millisecondsSinceEpoch.toString()),
    );

    await file.writeAsString(content);
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

    // TODO Windows
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

    if (Platform.isMacOS) {
      try {
        final result = await _channel.invokeMethod<bool>('modifyHostsFile',
            {'content': File(cacheFilePath).readAsStringSync()});

        if (result == null) {
          throw Exception("修改hosts文件失败");
        }
      } on PlatformException catch (e) {
        print('修改hosts文件失败: ${e.message}');
        throw e; // 重新抛出异常，让调用者处理
      }
    }

    return result;
  }

  Future<bool> exportHostFile(SimpleHostFile hostFile, String dialogTitle) async {
    try {
      if (_cachedDirectory == null) await _initializeDirectory();

      // 获取要导出的目录路径
      final String directoryPath = p.join(_cachedDirectory!.path, hostFile.fileName);
      final Directory exportDirectory = Directory(directoryPath);

      if (!await exportDirectory.exists()) {
        print('Directory does not exist: $directoryPath');
        return false;
      }

      // 让用户选择保存路径
      String? outputFilePath = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: '${hostFile.remark}_${hostFile.fileName}.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (outputFilePath != null) {
        // 创建压缩包
        final Archive archive = Archive();

        // 递归添加目录中的所有文件到压缩包
        await _addDirectoryToArchive(exportDirectory, archive, hostFile.fileName);

        // 编码压缩包
        final List<int> zipData = ZipEncoder().encode(archive)!;

        // 写入文件
        await File(outputFilePath).writeAsBytes(zipData);
        return true;
      }
      return false;
    } catch (e) {
      print('Export failed: $e');
      return false;
    }
  }

  // 递归添加目录到压缩包的辅助方法
  Future<void> _addDirectoryToArchive(
      Directory directory, Archive archive, String baseName) async {
    final List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final String relativePath = p.relative(entity.path,
            from: p.join(_cachedDirectory!.path, baseName));
        final List<int> fileBytes = await entity.readAsBytes();
        final ArchiveFile file =
            ArchiveFile(relativePath, fileBytes.length, fileBytes);
        archive.addFile(file);
      } else if (entity is Directory) {
        await _addDirectoryToArchive(entity, archive, baseName);
      }
    }
  }

  // 递归添加目录到压缩包的辅助方法（自定义文件夹名称）
  Future<void> _addDirectoryToArchiveWithCustomName(
      Directory directory, Archive archive, String baseName, String customFolderName) async {
    final List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final String relativePath = p.relative(entity.path,
            from: p.join(_cachedDirectory!.path, baseName));
        final String customPath = p.join(customFolderName, relativePath);
        final List<int> fileBytes = await entity.readAsBytes();
        final ArchiveFile file =
            ArchiveFile(customPath, fileBytes.length, fileBytes);
        archive.addFile(file);
      } else if (entity is Directory) {
        await _addDirectoryToArchiveWithCustomName(entity, archive, baseName, customFolderName);
      }
    }
  }

  Future<bool> exportMultipleHostFiles(List<SimpleHostFile> hostFiles, String dialogTitle) async {
    try {
      if (_cachedDirectory == null) await _initializeDirectory();
      
      if (hostFiles.isEmpty) {
        return false;
      }

      // 让用户选择保存路径
      String defaultFileName;
      if (hostFiles.length == 1) {
        // 单个文件时使用该文件的备注作为文件名
        defaultFileName = '${hostFiles.first.remark}_${hostFiles.first.fileName}.zip';
      } else {
        // 多个文件时使用通用名称
        defaultFileName = 'hosts_batch_export.zip';
      }
      
      String? outputFilePath = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (outputFilePath != null) {
        // 创建压缩包
        final Archive archive = Archive();

        // 为每个host文件添加到压缩包
        for (SimpleHostFile hostFile in hostFiles) {
          final String directoryPath = p.join(_cachedDirectory!.path, hostFile.fileName);
          final Directory exportDirectory = Directory(directoryPath);

          if (await exportDirectory.exists()) {
            // 创建以 {remark}_{fileName} 命名的文件夹
            final String folderName = '${hostFile.remark}_${hostFile.fileName}';
            await _addDirectoryToArchiveWithCustomName(exportDirectory, archive, hostFile.fileName, folderName);
          }
        }

        // 编码压缩包
        final List<int> zipData = ZipEncoder().encode(archive)!;

        // 写入文件
        await File(outputFilePath).writeAsBytes(zipData);
        return true;
      }
      return false;
    } catch (e) {
      print('Batch export failed: $e');
      return false;
    }
  }

  // 解析导入文件，返回可导入的hosts列表
  Future<List<ImportableHost>> parseImportFile(String filePath) async {
    List<ImportableHost> importableHosts = [];
    
    try {
      if (filePath.toLowerCase().endsWith('.zip')) {
        // 解析ZIP文件
        final bytes = await File(filePath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        // 查找所有可能的hosts文件夹
        Map<String, String> hostFolders = {};
        
        for (final file in archive) {
          if (file.isFile && file.name.endsWith('/hosts')) {
            // 获取文件夹名称
            final parts = file.name.split('/');
            if (parts.length >= 2) {
              final folderName = parts[parts.length - 2];
              hostFolders[folderName] = file.name;
            }
          }
        }
        
        // 为每个hosts文件夹创建ImportableHost
        for (final entry in hostFolders.entries) {
          final folderName = entry.key;
          final hostFilePath = entry.value;
          
          // 尝试解析文件夹名称为remark和fileName
          String remark = folderName;
          String fileName = folderName;
          
          // 如果文件夹名称包含下划线，尝试分割
          if (folderName.contains('_')) {
            final lastUnderscoreIndex = folderName.lastIndexOf('_');
            remark = folderName.substring(0, lastUnderscoreIndex);
            fileName = folderName.substring(lastUnderscoreIndex + 1);
          }
          
          importableHosts.add(ImportableHost(
            remark: remark,
            fileName: fileName,
            folderPath: hostFilePath.substring(0, hostFilePath.lastIndexOf('/')),
            hasContent: true,
          ));
        }
      } else {
        // 单个hosts文件
        final fileName = p.basenameWithoutExtension(filePath);
        importableHosts.add(ImportableHost(
          remark: fileName,
          fileName: fileName,
          folderPath: filePath,
          hasContent: await File(filePath).exists(),
        ));
      }
    } catch (e) {
      print('解析导入文件失败: $e');
    }
    
    return importableHosts;
  }

  // 导入选中的hosts文件
  Future<List<SimpleHostFile>> importSelectedHosts(String filePath, List<ImportableHost> selectedHosts, List<String> existingFileNames) async {
    List<SimpleHostFile> importedFiles = [];
    
    try {
      if (_cachedDirectory == null) await _initializeDirectory();
      
      if (filePath.toLowerCase().endsWith('.zip')) {
        // 从ZIP文件导入
        final bytes = await File(filePath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        for (final selectedHost in selectedHosts) {
          // 直接使用原文件名，如果存在则覆盖
          String fileName = selectedHost.fileName;
          String targetDir = p.join(_cachedDirectory!.path, fileName);
          
          // 如果目录已存在，先删除
          if (await Directory(targetDir).exists()) {
            await Directory(targetDir).delete(recursive: true);
          }
          
          // 创建目标目录
          await Directory(targetDir).create(recursive: true);
          await Directory(p.join(targetDir, 'history')).create(recursive: true);
          
          // 提取文件
          for (final file in archive) {
            if (file.isFile && file.name.startsWith(selectedHost.folderPath)) {
              final relativePath = file.name.substring(selectedHost.folderPath.length + 1);
              final targetPath = p.join(targetDir, relativePath);
              
              // 确保目标目录存在
              await Directory(p.dirname(targetPath)).create(recursive: true);
              
              // 写入文件
              await File(targetPath).writeAsBytes(file.content as List<int>);
            }
          }
          
          // 创建SimpleHostFile对象
          final importedFile = SimpleHostFile(
            fileName: fileName,
            remark: selectedHost.remark,
          );
          importedFiles.add(importedFile);
          existingFileNames.add(fileName);
        }
      } else {
        // 单个文件导入
        if (selectedHosts.isNotEmpty) {
          final selectedHost = selectedHosts.first;
          String fileName = selectedHost.fileName;
          String targetDir = p.join(_cachedDirectory!.path, fileName);
          
          // 如果目录已存在，先删除
          if (await Directory(targetDir).exists()) {
            await Directory(targetDir).delete(recursive: true);
          }
          
          // 创建目标目录
          await Directory(targetDir).create(recursive: true);
          await Directory(p.join(targetDir, 'history')).create(recursive: true);
          
          // 复制文件
          final sourceFile = File(filePath);
          final targetFile = File(p.join(targetDir, 'hosts'));
          await sourceFile.copy(targetFile.path);
          
          // 创建SimpleHostFile对象
          final importedFile = SimpleHostFile(
            fileName: fileName,
            remark: selectedHost.remark,
          );
          importedFiles.add(importedFile);
        }
      }
      
      return importedFiles;
    } catch (e) {
      print('导入失败: $e');
      return [];
    }
  }

  List<HostsModel> parseHosts(List<String> lines) {
    List<HostsModel> tempHosts = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && (isValidIPv4(line) || isValidIPv6(line))) {
        final parts = line
            .replaceFirst("#", "")
            .split(RegExp(r"\s+"))
            .where((it) => it.trim().isNotEmpty)
            .toList();

        if (parts.length < 2) continue;

        String host = parts.first;
        List<String> hosts = parts.sublist(1);

        int? descLine;
        String description = "";

        Map<String, dynamic> config = {};

        List<String> lineDescription = line.contains(RegExp(r"\s+#\s?"))
            ? line
                .split(RegExp(r"\s+#\s?"))
                .where((it) => it.trim().isNotEmpty)
                .toList()
            : [];

        if (lineDescription.isNotEmpty) {
          print(lineDescription);
          final List<String> tempLineDescription = lineDescription.sublist(1);
          final String temp = tempLineDescription.length > 1
              ? tempLineDescription.join("# ")
              : "# ${tempLineDescription.join("")}";

          final RegExp regExp = RegExp(r"# - config \{([^{}]*)\}");
          final String tempDescription = temp.contains(regExp)
              ? temp.replaceAll(regExp, "")
              : temp.replaceFirst("# ", "");
          if (tempDescription.trim().isNotEmpty) {
            description = tempDescription;
          }

          final RegExpMatch? match = regExp.firstMatch(temp);
          if (match != null) {
            try {
              config = jsonDecode("{${match.group(1)}}");
            } catch (e) {
              print("错误：解析配置失败");
            }
          }

          hosts = lineDescription.first
              .replaceFirst("#", "")
              .split(RegExp(r"\s+"))
              .where((it) => it.trim().isNotEmpty)
              .toList()
              .sublist(1);
        }

        if (i > 0 && description.isEmpty) {
          final prevLine = lines[i - 1].trim();
          if (prevLine.isNotEmpty &&
              prevLine.startsWith("#") &&
              !(isValidIPv4(prevLine) || isValidIPv6(prevLine))) {
            description = prevLine.replaceFirst(RegExp(r"^#\s?"), "");
            descLine = i - 1;
          }
        }

        tempHosts.add(HostsModel(host, !line.startsWith(RegExp(r"^\s?#")),
            description, hosts, config,
            hostLine: i, descLine: descLine));
      }
    }

    return tempHosts;
  }
}
