import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/global_settings.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/home/view/history_page.dart';
import 'package:hosts/widget/dialog/copy_multiple_dialog.dart';
import 'package:hosts/widget/snakbar.dart';
import 'package:hosts/widget/text_field/search_text_field.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 首页应用栏组件
///
/// 包含文件操作、搜索、历史记录等功能的顶部工具栏
class HomeAppBar extends StatelessWidget {
  /// 构造函数
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homeCubit = context.read<HomeCubit>();
        final homeStateData = state.data;
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                return Container(
                  height: isNarrow ? null : 58,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: isNarrow ? _buildNarrowLayout(context, homeCubit, homeStateData) : _buildWideLayout(context, homeCubit, homeStateData),
                );
              },
            )
          ],
        );
      },
    );
  }

  IconButton _buildEditModeButton(HomeCubit homeCubit, BuildContext context) {
    return IconButton(
      onPressed: () {
        if (homeCubit.state.data.editMode == EditMode.Text) {
          homeCubit.toggleEditMode(EditMode.Table);
        } else {
          homeCubit.toggleEditMode(EditMode.Text);
        }
      },
      tooltip: homeCubit.state.data.editMode == EditMode.Text
          ? AppLocalizations.of(context)!.table
          : AppLocalizations.of(context)!.text,
      icon: Icon(
        homeCubit.state.data.editMode == EditMode.Text
            ? Icons.table_rows_outlined
            : Icons.text_snippet_outlined,
      ),
    );
  }

  Widget batchGroupButton(HomeCubit homeCubit) {
    return BlocBuilder<HostCubit, HostState>(
      builder: (BuildContext context, state) {
        final selectHosts = state.data.selectHosts;
        final hostCubit = context.read<HostCubit>();
        return Row(
          children: [
            if (selectHosts.isNotEmpty &&
                homeCubit.state.data.editMode == EditMode.Table)
              Switch(
                value: true,
                onChanged: (value) {
                  final Map<HostsModel, HostsModel> hostsMap = {};
                  for (var host in selectHosts) {
                    hostsMap[host] = host.withCopy(isUse: true);
                  }
                  hostCubit.onToggleUse(hostsMap);
                },
              ),
            if (selectHosts.isNotEmpty &&
                homeCubit.state.data.editMode == EditMode.Table)
              Switch(
                value: false,
                onChanged: (value) {
                  final Map<HostsModel, HostsModel> hostsMap = {};
                  for (var host in selectHosts) {
                    hostsMap[host] = host.withCopy(isUse: false);
                  }
                  hostCubit.onToggleUse(hostsMap);
                },
              ),
            if (selectHosts.isNotEmpty &&
                homeCubit.state.data.editMode == EditMode.Table)
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            CopyMultipleDialog(hosts: selectHosts));
                  },
                  tooltip: AppLocalizations.of(context)!.copy_selected,
                  icon: const Icon(Icons.copy)),
            if (selectHosts.isNotEmpty &&
                homeCubit.state.data.editMode == EditMode.Table)
              IconButton(
                  onPressed: () {
                    deleteMultiple(
                        context, selectHosts.map((it) => it.host).toList(), () {
                      hostCubit.onDelete(selectHosts);
                    });
                  },
                  tooltip: AppLocalizations.of(context)!.delete_selected,
                  icon: const Icon(Icons.delete_outline)),
          ],
        );
      },
    );
  }

  void pickFile(BuildContext context, FilePickerResult result) {
    if (result.files.first.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.error_open_file_size)));
      return;
    }

    try {
      String path = "";
      try {
        path = result.files.single.path ?? "";
      } catch (e) {
        path = "";
      }
      final Uint8List? bytes = result.files.first.bytes;
      if (path.isNotEmpty && bytes == null) {
        context.read<HostCubit>().fromText(File(path).readAsStringSync());
      }

      if (bytes != null) {
        context.read<HostCubit>().fromText(utf8.decode(bytes));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.error_open_file)));
    }
  }

  Widget buildMoreButton(BuildContext context) {
    return PopupMenuButton(onSelected: (value) async {
      switch (value) {
        case 1:
          // 检查更新
          await _launchUrl(context, 'https://github.com/webb-l/hosts/releases');
          break;
        case 2:
          // 反馈问题
          await _launchUrl(context, 'https://github.com/webb-l/hosts/issues');
          break;
        case 3:
          // 关于
          final packageInfo = await PackageInfo.fromPlatform();
          
          if (context.mounted) {
            showAboutDialog(
              context: context,
              applicationVersion: packageInfo.version,
              applicationIcon: Image.asset(
                "assets/icon/logo.png",
                width: 50,
                height: 50,
              ),
              children: [
                Text(AppLocalizations.of(context)!.about_description),
                const SizedBox(height: 10),
                const Text('Developed by Webb.'),
              ],
            );
          }
          break;
        default:
          break;
      }
    }, itemBuilder: (BuildContext context) {
      final List<Map<String, Object>> list = [
        {
          "text": AppLocalizations.of(context)!.check_for_updates,
          "value": 1,
          "icon": Icons.system_update
        },
        {
          "text": AppLocalizations.of(context)!.report_issue, 
          "value": 2,
          "icon": Icons.bug_report
        },
        {
          "text": AppLocalizations.of(context)!.about,
          "value": 3,
          "icon": Icons.info
        },
      ];

      return list.map((item) {
        return PopupMenuItem<int>(
          value: int.parse(item["value"].toString()),
          child: Row(
            children: [
              if (item["icon"] != null) Icon(item["icon"]! as IconData),
              SizedBox(width: item["icon"] != null ? 8 : 0),
              Text(item["text"]!.toString()),
            ],
          ),
        );
      }).toList();
    });
  }

  /// 打开URL
  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.unable_to_open(url))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.unable_to_open(url)}: $e')),
        );
      }
    }
  }

  Widget _buildWideLayout(BuildContext context, HomeCubit homeCubit, HomeStateData homeStateData) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (GlobalSettings().isSimple)
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result == null) return;
                    if (!context.read<HostCubit>().state.data.isSave) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!.error_not_save),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.abort,
                          onPressed: () => pickFile(context, result),
                        ),
                      ));
                      return;
                    }
                    pickFile(context, result);
                  },
                  icon: const Icon(Icons.file_open_outlined),
                  tooltip: AppLocalizations.of(context)!.open_file,
                )
              else
                IconButton(
                  onPressed: homeCubit.toggleAdvancedSettingsSwitch,
                  icon: const Icon(Icons.menu),
                  tooltip: AppLocalizations.of(context)!.advanced_settings,
                ),
              _buildEditModeButton(homeCubit, context),
              const SizedBox(width: 10),
              if (homeStateData.editMode == EditMode.Table)
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                      minWidth: 100,
                    ),
                    child: BlocBuilder<HostCubit, HostState>(
                      builder: (context, state) {
                        return SearchTextField(
                          text: state.data.searchText,
                          onChanged: context.read<HostCubit>().updateSearchText,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        BlocBuilder<HostCubit, HostState>(
          builder: (context, state) {
            final hostStateData = state.data;
            final hostCubit = context.read<HostCubit>();
            return Row(
              children: [
                batchGroupButton(homeCubit),
                if (hostStateData.history.isNotEmpty)
                  IconButton(
                    onPressed: () async {
                      SimpleHostFileHistory? resultHistory = await showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => HistoryPage(
                          selectHistory: hostStateData.selectHistory,
                          history: hostStateData.history,
                          fileId: state.data.fileId,
                        ),
                      );
                      if (resultHistory == null) {
                        hostCubit.onHistoryChanged(null);
                        return;
                      }
                      if (!hostStateData.isSave) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(context)!.error_not_save),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)!.abort,
                            onPressed: () => hostCubit.onHistoryChanged(resultHistory),
                          ),
                        ));
                        return;
                      }
                      hostCubit.onHistoryChanged(resultHistory);
                    },
                    icon: const Icon(Icons.history),
                  ),
                if (!hostStateData.isSave)
                  IconButton(
                    onPressed: context.read<HostCubit>().undoHost,
                    icon: const Icon(Icons.undo),
                    tooltip: AppLocalizations.of(context)!.reduction,
                  ),
                buildMoreButton(context)
              ],
            );
          },
        )
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, HomeCubit homeCubit, HomeStateData homeStateData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (GlobalSettings().isSimple)
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result == null) return;
                    if (!context.read<HostCubit>().state.data.isSave) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!.error_not_save),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.abort,
                          onPressed: () => pickFile(context, result),
                        ),
                      ));
                      return;
                    }
                    pickFile(context, result);
                  },
                  icon: const Icon(Icons.file_open_outlined),
                  tooltip: AppLocalizations.of(context)!.open_file,
                )
              else
                IconButton(
                  onPressed: homeCubit.toggleAdvancedSettingsSwitch,
                  icon: const Icon(Icons.menu),
                  tooltip: AppLocalizations.of(context)!.advanced_settings,
                ),
              _buildEditModeButton(homeCubit, context),
              const Spacer(),
              BlocBuilder<HostCubit, HostState>(
                builder: (context, state) {
                  final hostStateData = state.data;
                  final hostCubit = context.read<HostCubit>();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildNarrowBatchActions(homeCubit),
                      ),
                      if (hostStateData.history.isNotEmpty)
                        IconButton(
                          onPressed: () async {
                            SimpleHostFileHistory? resultHistory = await showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) => HistoryPage(
                                selectHistory: hostStateData.selectHistory,
                                history: hostStateData.history,
                                fileId: state.data.fileId,
                              ),
                            );
                            if (resultHistory == null) {
                              hostCubit.onHistoryChanged(null);
                              return;
                            }
                            if (!hostStateData.isSave) {
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!.error_not_save),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.abort,
                                  onPressed: () => hostCubit.onHistoryChanged(resultHistory),
                                ),
                              ));
                              return;
                            }
                            hostCubit.onHistoryChanged(resultHistory);
                          },
                          icon: const Icon(Icons.history),
                          tooltip: AppLocalizations.of(context)!.history,
                        ),
                      if (!hostStateData.isSave)
                        IconButton(
                          onPressed: context.read<HostCubit>().undoHost,
                          icon: const Icon(Icons.undo),
                          tooltip: AppLocalizations.of(context)!.reduction,
                        ),
                      buildMoreButton(context)
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (homeStateData.editMode == EditMode.Table)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<HostCubit, HostState>(
                    builder: (context, state) {
                      return SearchTextField(
                        text: state.data.searchText,
                        onChanged: context.read<HostCubit>().updateSearchText,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNarrowBatchActions(HomeCubit homeCubit) {
    return BlocBuilder<HostCubit, HostState>(
      builder: (BuildContext context, state) {
        final selectHosts = state.data.selectHosts;
        final hostCubit = context.read<HostCubit>();
        
        if (selectHosts.isEmpty || homeCubit.state.data.editMode != EditMode.Table) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Switch(
                value: true,
                onChanged: (value) {
                  final Map<HostsModel, HostsModel> hostsMap = {};
                  for (var host in selectHosts) {
                    hostsMap[host] = host.withCopy(isUse: true);
                  }
                  hostCubit.onToggleUse(hostsMap);
                },
              ),
              Switch(
                value: false,
                onChanged: (value) {
                  final Map<HostsModel, HostsModel> hostsMap = {};
                  for (var host in selectHosts) {
                    hostsMap[host] = host.withCopy(isUse: false);
                  }
                  hostCubit.onToggleUse(hostsMap);
                },
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CopyMultipleDialog(hosts: selectHosts),
                  );
                },
                tooltip: AppLocalizations.of(context)!.copy_selected,
                icon: const Icon(Icons.copy),
              ),
              IconButton(
                onPressed: () {
                  deleteMultiple(
                    context,
                    selectHosts.map((it) => it.host).toList(),
                    () {
                      hostCubit.onDelete(selectHosts);
                    },
                  );
                },
                tooltip: AppLocalizations.of(context)!.delete_selected,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }
}
