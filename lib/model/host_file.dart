import 'dart:io';

import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/regexp_util.dart';

class HostsModel {
  String host;
  bool isUse;
  String description;
  final List<String> hosts;
  int? hostLine;
  int? descLine;

  HostsModel(this.host, this.isUse, this.description, this.hosts,
      {this.hostLine, this.descLine});

  @override
  String toString() {
    String text = "";
    if (description.isNotEmpty) {
      text += "# $description";
    }
    if (text.isNotEmpty) {
      text += "\n";
    }

    return "$text${isUse ? "" : "# "}$host ${hosts.join(" ")}";
  }

  filter(String searchQuery) {
    if (searchQuery.isEmpty) return true;
    return host.contains(searchQuery) ||
        description.contains(searchQuery) ||
        hosts.where((it) => it.contains(searchQuery)).isNotEmpty;
  }
}

class HostsFile {
  late File _file;
  final String filePath;
  final String fileId;

  late String defaultContent;

  // 是否保存
  bool isSave = true;

  final List<HostsModel> hosts = [];
  List<String> _lines = [];
  List<SimpleHostFileHistory> history = [];

  HostsFile(this.filePath, this.fileId) {
    if (filePath.isEmpty || fileId.isEmpty) return;
    initData();
    FileManager().getHistory(fileId).then((value){
      history = value;
    });
  }

  void initData() {
    try {
      _file = File(filePath);
      _lines = _file.readAsLinesSync();
      defaultContent = toString().replaceAll(" ", "").replaceAll("	", "");
      _parseHosts(_lines);
    } catch (e) {
      print('读取 hosts 文件时发生错误: $e');
    }
  }

  int count() {
    return hosts.length;
  }

  List<HostsModel> filterHosts(
      String searchQuery, Map<String, int?> sortConfig) {
    hosts.sort((a, b) {
      for (var property in sortConfig.keys) {
        final order = sortConfig[property];
        int comparisonResult;
        switch (property) {
          case 'isUse':
            comparisonResult = a.isUse == b.isUse ? 0 : (a.isUse ? 1 : -1);
            break;
          case 'host':
            comparisonResult = a.host.compareTo(b.host);
            break;
          case 'description':
            comparisonResult = a.description.compareTo(b.description);
            break;
          case 'hosts':
            comparisonResult = a.hosts.toString().compareTo(b.hosts.toString());
          default:
            comparisonResult = 0;
        }
        if (order == 1) {
          comparisonResult = -comparisonResult;
        } else if (order == 2) {
          comparisonResult = comparisonResult;
        } else {
          continue;
        }

        if (comparisonResult != 0) {
          return comparisonResult;
        }
      }
      return 0;
    });
    return hosts.where((host) => host.filter(searchQuery)).toList();
  }

  @override
  String toString() {
    return _lines.join("\n");
  }

  void isUpdateHost() {
    isSave =
        defaultContent == toString().replaceAll(" ", "").replaceAll("	", "");
  }

  void formString(String text) {
    _lines = text.split("\n");
    _parseHosts(_lines);
  }

  void _parseHosts(List<String> lines) {
    List<HostsModel> tempHosts = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      // 找出是 hosts 配置的行
      if (line.isNotEmpty && (isValidIPv4(line) || isValidIPv6(line))) {
        // 解析 hosts 配置
        final parts = line
            .replaceFirst("#", "")
            .split(RegExp(r'\s+'))
            .map((it) => it.trim())
            .where((it) => it.isNotEmpty)
            .toList();

        if (parts.length < 2) continue;

        int? descLine;
        String description = "";

        if (i > 0) {
          final prevLine = lines[i - 1].trim();
          if (prevLine.isNotEmpty &&
              prevLine.startsWith("#") &&
              !(isValidIPv4(prevLine) || isValidIPv6(prevLine))) {
            description = prevLine.replaceFirst(RegExp("^#\\s?"), "");
            descLine = i - 1;
          }
        }

        tempHosts.add(HostsModel(
            parts.first, !line.startsWith("#"), description, parts.sublist(1),
            hostLine: i, descLine: descLine));
      }
    }

    hosts.clear();
    hosts.addAll(tempHosts);
  }

  addHost(HostsModel model) {
    _lines.addAll(model.toString().split("\n"));
    _parseHosts(_lines);
    isUpdateHost();
  }

  updateHost(int index, HostsModel model) {
    HostsModel oldHosts = hosts[index];

    model.descLine ??= oldHosts.descLine;
    model.hostLine = oldHosts.hostLine;

    final List<String> newLine = model.toString().split("\n");
    if (model.descLine != null &&
        model.descLine! > -1 &&
        [2].contains(newLine.length)) {
      _lines[model.descLine!] = newLine[0];
    }

    if (model.hostLine != null &&
        model.hostLine! > -1 &&
        [1, 2].contains(newLine.length)) {
      _lines[model.hostLine!] = newLine.length == 2 ? newLine[1] : newLine[0];
    }

    // 新增备注
    if (model.descLine == null && model.description.isNotEmpty) {
      _lines.insert(model.hostLine!, "# ${model.description}");
    }
    // 移除备注
    if (model.descLine != null && model.description.isEmpty) {
      _lines.removeAt(model.descLine!);
    }

    _parseHosts(_lines);
    isUpdateHost();
  }

  void deleteMultiple(List<HostsModel> models) {
    models.sort((a, b) => a.hostLine?.compareTo(b.hostLine ?? -1) ?? 1);
    int removeCount = 0;
    for (var model in models) {
      if (model.descLine != null && model.descLine! > -1) {
        _lines.removeAt(model.descLine! - removeCount);
        removeCount++;
      }
      if (model.hostLine != null && model.hostLine! > -1) {
        _lines.removeAt(model.hostLine! - removeCount);
        removeCount++;
      }
    }

    isUpdateHost();
    _parseHosts(_lines);
  }

  void save([bool isHistory = false]) {
    final String content = toString();
    File(filePath).writeAsStringSync(content);
    if (isHistory) {
      FileManager fileManager = FileManager();
      fileManager.saveHistory(fileId, content);
      fileManager.getHistory(fileId).then((value){
        history = value;
      });
    }
    initData();
    isUpdateHost();
    isSave = true;
  }
}
