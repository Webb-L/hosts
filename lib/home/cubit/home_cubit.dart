import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/l10n/app_localizations.dart' as gen;
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/util/string_util.dart';

part 'home_state.dart';

/// 首页业务逻辑处理类
/// 管理首页的所有状态变更
class HomeCubit extends Cubit<HomeState> {
  /// 构造函数
  /// 初始化状态为HomeInitial
  HomeCubit() : super(const HomeInitial(HomeStateData()));

  /// 设置管理器
  final SettingsManager _settingsManager = SettingsManager();

  /// 文件管理器
  final FileManager _fileManager = FileManager();

  /// 加载host文件列表
  /// [context] 用于本地化
  /// [isInit] 是否为初始化加载
  Future<void> loadHostFiles(BuildContext context,
      [bool isInit = false]) async {
    List<SimpleHostFile> tempHostFiles = [];
    List<String> tempSelectHostFiles = [];
    List<dynamic> hostConfigs =
    await _settingsManager.getList(settingKeyHostConfigs);

    if (isInit) {
      // TODO 支持多个文件选择
      tempSelectHostFiles = [
        (await _settingsManager.getString(settingKeyUseHostFile) ?? "")
      ];
    }

    for (Map<String, dynamic> config in hostConfigs) {
      SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
      tempHostFiles.add(hostFile);

      if (hostFile.fileName == "system") {
        hostFile.remark = gen.AppLocalizations.of(context)!.default_hosts_text;
      }
    }

    final fileId =
    tempSelectHostFiles.isNotEmpty ? tempSelectHostFiles.first : "system";

    emit(
      HomeInitial(
        HomeStateData(
          hostFiles: tempHostFiles,
          useHostFiles: tempSelectHostFiles,
          editMode: EditMode.Table,
        ),
      ),
    );

    selectHost(fileId);
  }

  /// 添加新的host文件
  /// [remark] 文件备注信息
  Future<void> addHostFile(String remark) async {
    if (remark.isEmpty) return;

    // 获取当前 hostFiles 列表
    List<SimpleHostFile> currentHostFiles = List.from(state.data.hostFiles);
    List<dynamic> hostConfigs =
    await _settingsManager.getList(settingKeyHostConfigs);

    // 生成随机文件名
    final String fileName = generateRandomString(18);

    // 创建新的 hostFile
    SimpleHostFile newHostFile =
    SimpleHostFile(fileName: fileName, remark: remark);

    // 添加到 hostFiles 列表
    currentHostFiles.add(newHostFile);
    hostConfigs.add(newHostFile.toJson());

    // 创建实际的文件
    await _fileManager.createHosts(fileName);

    // 保存到
    await _settingsManager.setList(settingKeyHostConfigs, hostConfigs);

    // 更新状态
    emit(
      HomeInitial(
        state.data.copyWith(
          hostFiles: currentHostFiles,
        ),
      ),
    );
  }

  /// 更新host文件备注
  /// [fileName] 要更新的文件名
  /// [newRemark] 新的备注信息
  Future<void> updateHostFileRemark(String fileName, String newRemark) async {
    if (fileName.isEmpty || newRemark.isEmpty) return;

    List<SimpleHostFile> updatedHostFiles = [];
    List<dynamic> hostConfigs =
    await _settingsManager.getList(settingKeyHostConfigs);

    bool updated = false;

    // 更新 hostFiles
    for (SimpleHostFile hostFile in state.data.hostFiles) {
      if (hostFile.fileName == fileName) {
        updatedHostFiles
            .add(SimpleHostFile(fileName: fileName, remark: newRemark));
        updated = true;
      } else {
        updatedHostFiles.add(hostFile);
      }
    }

    if (!updated) return;

    // 更新 hostConfigs
    List<Map<String, dynamic>> updatedConfigs = [];
    for (var config in hostConfigs) {
      if (config['fileName'] == fileName) {
        updatedConfigs.add({'fileName': fileName, 'remark': newRemark});
      } else {
        updatedConfigs.add(config);
      }
    }

    // 保存到 settings
    await _settingsManager.setList(settingKeyHostConfigs, updatedConfigs);

    // 更新状态
    emit(
      HomeInitial(
        state.data.copyWith(
          hostFiles: updatedHostFiles,
        ),
      ),
    );
  }

  /// 删除host文件
  /// [fileName] 要删除的文件名
  Future<void> deleteHostFile(String fileName) async {
    if (fileName.isEmpty || fileName == "system") return;

    // 判断是否删除使用的 Host 文件
    final bool isDeleteUse = state.data.useHostFiles.contains(fileName);
    // 判断是否删除选择的 Host 文件
    final bool isDeleteSelect = state.data.selectHostFile == fileName;

    if (isDeleteUse) {
      // TODO
      // final String path =
      //     await _fileManager.getHostsFilePath("system");
      //
      // if (!await widget
      //     .onClickUse(File(path).readAsStringSync())) {
      //   return;
      // }
      // await _settingsManager.setString(
      //     settingKeyUseHostFile, "system");
      // useHostFile = "system";
      // selectHostFile = "system";
    }

    if (isDeleteSelect) {
      selectHost(
        state.data.selectHostFile.isNotEmpty
            ? state.data.selectHostFile
            : "system",
      );
    }

    List<SimpleHostFile> updatedHostFiles = state.data.hostFiles
        .where((file) => file.fileName != fileName)
        .toList();

    List<dynamic> hostConfigs =
    await _settingsManager.getList(settingKeyHostConfigs);

    hostConfigs.removeWhere((config) => config['fileName'] == fileName);

    // 保存到 settings
    await _settingsManager.setList(settingKeyHostConfigs, hostConfigs);

    // 删除实际文件
    await _fileManager.deleteFiles([fileName]);

    // 更新状态
    emit(
      HomeInitial(
        state.data.copyWith(
          hostFiles: updatedHostFiles,
        ),
      ),
    );
  }

  /// 选择host文件
  /// [fileId] 要选择的文件ID
  Future<void> selectHost(String fileId) async {
    emit(
      HomeSelectHostFileChanged(
        state.data.copyWith(
          selectHostFile: fileId,
        ),
      ),
    );
  }

  /// 使用host文件
  /// [fileName] 要使用的文件名
  Future<void> useHost(String fileName) async {}

  /// 切换编辑模式
  /// [editMode] 新的编辑模式(表格/文本)
  Future<void> toggleEditMode(EditMode editMode) async {
    emit(
      HomeEditMode(
        state.data.copyWith(
          editMode: editMode,
        ),
      ),
    );
  }

  /// 切换高级设置状态
  /// [advancedSettings] 新的高级设置状态
  Future<void> toggleAdvancedSettings(
      AdvancedSettingsEnum advancedSettings) async {
    emit(
      HomeAdvancedSettings(
        state.data.copyWith(
          advancedSettingsEnum: advancedSettings,
        ),
      ),
    );
  }

  /// 切换高级设置开关状态
  /// 在Open和Close之间切换
  Future<void> toggleAdvancedSettingsSwitch() async {
    final AdvancedSettingsEnum newSettings =
    state.data.advancedSettingsEnum == AdvancedSettingsEnum.Close
        ? AdvancedSettingsEnum.Open
        : AdvancedSettingsEnum.Close;

    await toggleAdvancedSettings(newSettings);
  }

  /// 刷新hosts文件列表
  /// [context] 可选的context参数，用于system文件的本地化
  Future<void> refreshHostFiles([BuildContext? context]) async {
    List<SimpleHostFile> tempHostFiles = [];
    List<dynamic> hostConfigs =
        await _settingsManager.getList(settingKeyHostConfigs);

    for (Map<String, dynamic> config in hostConfigs) {
      SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
      tempHostFiles.add(hostFile);

      // 特殊处理system文件的remark
      if (hostFile.fileName == "system") {
        if (context != null) {
          hostFile.remark = gen.AppLocalizations.of(context)!.default_hosts_text;
        } else {
          hostFile.remark = "默认"; // 后备文本
        }
      }
    }

    emit(
      HomeInitial(
        state.data.copyWith(
          hostFiles: tempHostFiles,
        ),
      ),
    );
  }
}
