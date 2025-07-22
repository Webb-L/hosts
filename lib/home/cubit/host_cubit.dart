/// 主机管理模块的Cubit实现
///
/// 负责管理主机文件的状态和业务逻辑
library;

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'host_state.dart';

// 确保已正确导入HostSort状态类
/// 主机管理Cubit类
///
/// 继承自Cubit<HostState>，管理主机文件的各种状态变更
class HostCubit extends Cubit<HostState> {
  /// 构造函数
  ///
  /// 初始化状态为HostInitial
  HostCubit() : super(HostInitial(HostStateData()));

  /// 文件管理器实例
  final FileManager _fileManager = FileManager();

  /// 更新搜索文本
  ///
  /// [text]: 新的搜索文本
  void updateSearchText(String text) {
    emit(
      HostFilter(
        state.data.copyWith(
          searchText: text,
          filterHosts:
              state.data.hosts.where((host) => host.filter(text)).toList(),
        ),
      ),
    );
  }

  /// 更新选中的主机列表
  ///
  /// [selectHosts]: 新的选中主机列表
  void updateSelectHosts(List<HostsModel> selectHosts) {
    emit(
      HostInitial(
        state.data.copyWith(
          selectHosts: selectHosts,
        ),
      ),
    );
  }

  /// 更新全选状态
  ///
  /// [isCheckedAll]: 是否全选
  void updateCheckedAll(bool? isCheckedAll) {
    emit(
      HostInitial(
        state.data.copyWith(
          selectHosts: isCheckedAll == true ? state.data.filterHosts : [],
        ),
      ),
    );
  }

  /// 更新主机文件内容
  ///
  /// [fileId]: 文件ID
  void updateHost(String fileId) async {
    final content = await _fileManager.readAsString(fileId);
    final hosts = _fileManager.parseHosts(content.split("\n"));
    final history = await _fileManager.getHistory(fileId);

    emit(
      HostInitial(
        HostStateData(
          fileId: fileId,
          fileContent: content,
          defaultFileContent: content,
          hosts: hosts,
          defaultHosts: hosts,
          filterHosts: hosts,
          history: history,
        ),
      ),
    );
  }

  /// 更新编辑模式
  ///
  /// [editMode]: 新的编辑模式(表格/文本)
  /// 根据编辑模式切换显示方式
  void updateEditMode(EditMode editMode) {
    if (editMode == EditMode.Table) {
      final hosts = _fileManager.parseHosts(state.data.fileContent.split("\n"));
      emit(
        HostEditMode(
          state.data.copyWith(
            hosts: hosts,
            filterHosts: hosts,
          ),
        ),
      );
    }
    if (editMode == EditMode.Text) {
      emit(
        HostEditMode(
          state.data.copyWith(
            fileContent: toString(),
          ),
        ),
      );
    }
  }

  /// 编辑主机项
  ///
  /// [index]: 主机索引
  /// [host]: 新的主机数据
  void onEdit(int index, HostsModel host) {
    final List<HostsModel> updatedHosts =
        List<HostsModel>.from(state.data.hosts);

    HostsModel oldHost = updatedHosts[index];

    host.descLine ??= oldHost.descLine;
    host.hostLine = oldHost.hostLine;

    final lines = state.data.fileContent.split("\n");

    final List<String> newLine = host.toString().split("\n");
    if (host.descLine != null &&
        host.descLine! > -1 &&
        [2].contains(newLine.length)) {
      lines[host.descLine!] = newLine[0];
    }

    if (host.hostLine != null &&
        host.hostLine! > -1 &&
        [1, 2].contains(newLine.length)) {
      lines[host.hostLine!] = newLine.length == 2 ? newLine[1] : newLine[0];
    }

    // 新增备注
    if (host.descLine == null && host.description.isNotEmpty) {
      lines.insert(host.hostLine!, "# ${host.description}");
    }

    // 移除备注
    if (host.descLine != null && host.description.isEmpty) {
      lines.removeAt(host.descLine!);
    }

    updatedHosts[index] = host;

    emit(
      HostEdit(
        state.data.copyWith(
          hosts: updatedHosts,
          filterHosts: updatedHosts
              .where((host) => host.filter(state.data.searchText))
              .toList(),
          isSave: isUpdate(updatedHosts),
          fileContent: lines.join("\n"),
        ),
      ),
    );
  }

  /// 切换主机使用状态
  ///
  /// [hostsMap]: 主机映射关系
  void onToggleUse(Map<HostsModel, HostsModel> hostsMap) {
    final lines = state.data.fileContent.split("\n");

    final List<HostsModel> updatedHosts = state.data.hosts.map((host) {
      return hostsMap.containsKey(host) ? hostsMap[host]! : host;
    }).toList();

    for (var host in updatedHosts) {
      if (host.hostLine == null) {
        continue;
      }
      lines[host.hostLine!] = host.toHostString();
    }

    emit(
      HostToggleUse(
        state.data.copyWith(
            hosts: updatedHosts,
            filterHosts: updatedHosts
                .where((host) => host.filter(state.data.searchText))
                .toList(),
            selectHosts: state.data.selectHosts.isNotEmpty
                ? hostsMap.values.toList()
                : [],
            isSave: isUpdate(updatedHosts),
            fileContent: lines.join("\n")),
      ),
    );
  }

  /// 删除主机项
  ///
  /// [hosts]: 要删除的主机列表
  void onDelete(List<HostsModel> hosts) {
    final newHosts =
        state.data.hosts.where((host) => !hosts.contains(host)).toList();
    hosts.sort((a, b) => a.hostLine?.compareTo(b.hostLine ?? -1) ?? 1);
    final lines = state.data.fileContent.split("\n");

    int removeCount = 0;
    for (var host in hosts) {
      if (host.descLine != null && host.descLine == host.hostLine) {
        lines.removeAt(host.descLine! - removeCount);
        removeCount++;
        continue;
      }

      if (host.descLine != null && host.descLine! > -1) {
        lines.removeAt(host.descLine! - removeCount);
        removeCount++;
      }
      if (host.hostLine != null && host.hostLine! > -1) {
        lines.removeAt(host.hostLine! - removeCount);
        removeCount++;
      }
    }
    emit(
      HostDelete(
        state.data.copyWith(
          hosts: newHosts,
          filterHosts: newHosts
              .where((host) => host.filter(state.data.searchText))
              .toList(),
          selectHosts: state.data.selectHosts
              .where((host) => !hosts.contains(host))
              .toList(),
          isSave: isUpdate(newHosts),
          fileContent: lines.join("\n"),
        ),
      ),
    );
  }

  /// 选中/取消选中主机项
  ///
  /// [index]: 主机索引
  /// [host]: 主机数据
  void onChecked(int index, HostsModel host) {
    final List<HostsModel> updatedSelectHosts =
        List<HostsModel>.from(state.data.selectHosts);
    if (updatedSelectHosts.contains(host)) {
      updatedSelectHosts.remove(host);
    } else {
      updatedSelectHosts.add(host);
    }

    emit(
      HostChecked(
        state.data.copyWith(
          selectHosts: updatedSelectHosts,
        ),
      ),
    );
  }

  /// 排序主机列表
  ///
  /// [columnName]: 列名
  /// [sortDirection]: 排序方向
  void onSort(String columnName) {
    // 获取当前排序状态
    final currentDirection = state.data.sortStatus[columnName];
    SortDirection newDirection;

    // 确定新的排序方向（两态循环）
    if (currentDirection == SortDirection.ascending) {
      newDirection = SortDirection.descending;
    } else {
      newDirection = SortDirection.ascending;
    }

    // 排序当前列表
    List<HostsModel> sortedHosts = List.from(state.data.hosts);
    sortedHosts.sort((a, b) {
      int result;
      switch (columnName) {
        case 'host':
          result = a.host.compareTo(b.host);
          break;
        case 'use':
          result = a.isUse == b.isUse ? 0 : (a.isUse ? 1 : -1);
          break;
        case 'hosts':
          result = a.hosts.join(',').compareTo(b.hosts.join(','));
          break;
        case 'description':
          result = a.description.compareTo(b.description);
          break;
        default:
          result = 0;
      }
      return newDirection == SortDirection.ascending ? result : -result;
    });

    emit(
      HostSort(
        state.data.copyWith(
          hosts: sortedHosts,
          filterHosts: sortedHosts
              .where((host) => host.filter(state.data.searchText))
              .toList(),
          sortStatus: {columnName: newDirection},
        ),
      ),
    );
  }

  /// 添加主机项
  ///
  /// [hostsModels]: 要添加的主机列表
  void addHosts(List<HostsModel> hostsModels) {
    final List<HostsModel> hosts = List<HostsModel>.from(state.data.hosts);
    final lines = state.data.fileContent.split("\n");

    for (var host in hostsModels) {
      final newLine = host.toString().split("\n");
      if (newLine.isEmpty) {
        continue;
      }
      if (newLine.length == 2) {
        hosts.add(
          host.withCopy(
            descLine: lines.length,
            hostLine: lines.length + 1,
          ),
        );
      }
      if (newLine.length == 1) {
        hosts.add(
          host.withCopy(
            hostLine: lines.length,
          ),
        );
      }
      lines.addAll(newLine);
    }

    emit(
      HostAdd(
        state.data.copyWith(
          hosts: hosts,
          filterHosts: hosts
              .where((host) => host.filter(state.data.searchText))
              .toList(),
          isSave: isUpdate(hosts),
          fileContent: lines.join("\n"),
        ),
      ),
    );
  }

  /// 撤销操作
  void undoHost() {
    emit(
      HostUndo(
        state.data.copyWith(
          hosts: state.data.defaultHosts,
          filterHosts: state.data.defaultHosts,
          selectHosts: [],
          fileContent: state.data.defaultFileContent,
          isSave: true,
        ),
      ),
    );
  }

  /// 历史记录变更处理
  ///
  /// [history]: 选中的历史记录
  void onHistoryChanged(SimpleHostFileHistory? history) async {
    final resultHistory = await _fileManager.getHistory(state.data.fileId);
    if (history != null) {
      final historyContent = _fileManager.readHistoryFile(history.path);
      final hosts = _fileManager.parseHosts(historyContent.split("\n"));
      emit(
        HostHistory(
          state.data.copyWith(
            selectHistory: history,
            history: resultHistory,
            hosts: hosts,
            filterHosts: hosts,
            isSave: false,
            fileContent: historyContent,
          ),
        ),
      );

      return;
    }

    emit(
      HostHistory(
        state.data.copyWith(
          selectHistory: null,
          history: resultHistory,
        ),
      ),
    );
  }

  /// 更新文件内容
  ///
  /// [text]: 新的文件内容
  void updateFileContent(String text) {
    if (text == state.data.defaultFileContent) {
      return;
    }
    emit(
      HostFileContent(
        state.data.copyWith(
          fileContent: text,
          isSave: text == state.data.defaultFileContent,
        ),
      ),
    );
  }

  void fromText(String content) {
    final hosts = _fileManager.parseHosts(content.split("\n"));

    emit(
      HostInitial(
        HostStateData(
          fileContent: content,
          defaultFileContent: content,
          hosts: hosts,
          defaultHosts: hosts,
          filterHosts: hosts,
        ),
      ),
    );
  }

  /// 检查是否有更新
  ///
  /// [hosts]: 当前主机列表
  /// 返回: 是否有更新
  bool isUpdate(List<HostsModel> hosts) {
    if (hosts.length != state.data.defaultHosts.length) return false;

    for (int i = 0; i < hosts.length; i++) {
      if (hosts[i].toString() != state.data.defaultHosts[i].toString()) {
        return false;
      }
    }

    return true;
  }

  void onTableSave(
    BuildContext context,
    HomeStateData homeStateData,
    bool isHistory,
  ) async {
    if (homeStateData.useHostFiles.contains(state.data.fileId)) {
      if (!await saveHost(
        context,
        FileManager.systemHostFilePath,
        state.data.fileContent,
      )) {
        return;
      }
    }
    save(isHistory);
  }

  // TODO 保存到文件中。
  void onTextSave() {
    // state.data.fileContent
  }

  void saveToFile() {}

  void save([bool isHistory = false]) async {
    final fileId = state.data.fileId;
    final String content = toString();
    final filePath = await _fileManager.getHostsFilePath(fileId);
    File(filePath).writeAsStringSync(content);
    final List<SimpleHostFileHistory> history = [];
    if (isHistory) {
      await _fileManager.saveHistory(fileId, state.data.defaultFileContent);
      history.addAll(await _fileManager.getHistory(fileId));
    }

    emit(
      HostSave(
        state.data.copyWith(
          history: isHistory ? history : state.data.history,
          defaultHosts: state.data.hosts,
          defaultFileContent: state.data.fileContent,
          isSave: true,
        ),
      ),
    );
  }

  Future<bool> saveHost(
      BuildContext context, String filePath, String hostContent) async {
    if (kIsWeb) {
      final String tempContent = hostContent.replaceAll("\"", "\\\"");
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("保存"),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: SelectableText(hostContent),
                ),
                actions: [
                  TextButton(
                      onPressed: () => writeClipboard(
                            'echo "$tempContent" > /etc/hosts',
                            tempContent,
                            context,
                          ),
                      child: const Text("Linux(echo)")),
                  TextButton(
                      onPressed: () {
                        final String systemHostPath = p.joinAll([
                          "C:",
                          "Windows",
                          "System32",
                          "drivers",
                          "etc",
                          "hosts"
                        ]);
                        final String content = hostContent
                            .split("\n")
                            .map((item) => 'echo $item')
                            .join("\n");
                        writeClipboard(
                          '(\n$content\n) > $systemHostPath',
                          hostContent,
                          context,
                        );
                      },
                      child: const Text("Windows(echo)")),
                  TextButton(
                      onPressed: () => writeClipboard(
                            'echo "$tempContent" > /etc/hosts',
                            tempContent,
                            context,
                          ),
                      child: const Text("MacOS(echo)")),
                ],
              ));
      return true;
    }

    final File file = File(filePath);
    try {
      await file.writeAsString(hostContent);
    } catch (e) {
      try {
        final Directory cacheDirectory = await getApplicationCacheDirectory();
        final File cacheFile = File(p.join(cacheDirectory.path, 'hosts'));
        await cacheFile.writeAsString(hostContent);

        await _fileManager.writeFileWithAdminPrivileges(
            cacheFile.path, filePath);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.error_save_fail)));
        return false;
      }
    }

    // emit(
    //   HostSave(
    //     state.data.copyWith(
    //       defaultHosts: state.data.hosts,
    //       defaultFileContent: state.data.fileContent,
    //       isSave: true,
    //     ),
    //   ),
    // );
    // setState(() {
    //   hostsFile.defaultContent = hostContent;
    //   hostsFile.isUpdateHost();
    // });
    return true;
  }

  void writeClipboard(
      String hostContent, String defaultContent, BuildContext context) {
    Clipboard.setData(ClipboardData(text: hostContent)).then((_) {
      // emit(
      //   HostSave(
      //     state.data.copyWith(
      //       defaultHosts: state.data.hosts,
      //       defaultFileContent: state.data.fileContent,
      //       isSave: true,
      //     ),
      //   ),
      // );
      // setState(() {
      //   hostsFile.defaultContent = defaultContent;
      //   hostsFile.isUpdateHost();
      // });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.copy_to_tip),
        ),
      );
    });
  }

  /// 转换为字符串
  ///
  /// 返回当前文件内容字符串
  @override
  String toString() {
    return state.data.fileContent;
  }

  Future<bool> areFilesEqual(String fileId) async {
    return await _fileManager.areFilesEqual(fileId);
  }

  Future<bool> saveFromText(String text) async {
    try {
      final filePath = await _fileManager.getHostsFilePath(state.data.fileId);
      await _fileManager.saveHistory(
        state.data.fileId,
        File(filePath).readAsStringSync(),
      );

      File(filePath).writeAsStringSync(text);

      return true;
    } catch (e) {
      return false;
    }
  }
}
