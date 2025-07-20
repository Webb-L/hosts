import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/server/view/server_settings_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/widget/dialog/dialog.dart';
import 'package:hosts/widget/dialog/export_hosts_dialog.dart';
import 'package:hosts/widget/dialog/import_hosts_dialog.dart';
import 'package:hosts/widget/snakbar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.app_name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () async {
                            String? remark = await hostConfigDialog(context);
                            if (remark == null || remark.isEmpty) return;
                            context.read<HomeCubit>().addHostFile(remark);
                          },
                          icon: const Icon(Icons.add)),
                      _buildOptionsMenu(context, state),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.data.hostFiles.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final hostFile = state.data.hostFiles[index];
                      return ListTile(
                        title: Text(hostFile.remark),
                        leading: IconButton(
                          tooltip: AppLocalizations.of(context)!.use,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: state.data.useHostFiles
                                  .contains(hostFile.fileName)
                              ? null
                              : () async {
                                  final result = await context
                                      .read<HomeCubit>()
                                      .useHost(hostFile.fileName);
                                  if (!result) {
                                    // 使用SnackBar提示错误
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .error_use_fail),
                                      ),
                                    );
                                  }
                                },
                          icon: Icon(state.data.useHostFiles
                                  .contains(hostFile.fileName)
                              ? Icons.star
                              : Icons.star_border),
                        ),
                        selectedTileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        selected:
                            state.data.selectHostFile == hostFile.fileName,
                        trailing: buildMoreButton(hostFile),
                        onTap: () async {
                          if (state.data.selectHostFile == hostFile.fileName) {
                            return;
                          }

                          if (!context.read<HostCubit>().state.data.isSave) {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .error_not_save),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.abort,
                                  onPressed: () {
                                    context
                                        .read<HomeCubit>()
                                        .selectHost(hostFile.fileName);
                                  },
                                ),
                              ),
                            );
                            return;
                          }

                          context
                              .read<HomeCubit>()
                              .selectHost(hostFile.fileName);

                          if (state.data.useHostFiles
                              .contains(hostFile.fileName)) {
                            if (!await context
                                .read<HostCubit>()
                                .areFilesEqual(hostFile.fileName)) {
                              final homeCubit = context.read<HomeCubit>();
                              final hostCubit = context.read<HostCubit>();
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(dialogContext)!
                                          .warning),
                                      content: Text(
                                          AppLocalizations.of(dialogContext)!
                                              .warning_different),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            final result = await homeCubit.useHost(hostFile.fileName);
                                            if (!result) {
                                              // 使用SnackBar提示错误
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .error_use_fail),
                                                ),
                                              );
                                              return;
                                            }

                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: Text(AppLocalizations.of(
                                                  dialogContext)!
                                              .warning_different_covering_system),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // TODO 没有写入到文件页面。 Text模式也没有更新内容。
                                            hostCubit.fromText(
                                                  File(FileManager
                                                          .systemHostFilePath)
                                                      .readAsStringSync(),
                                                );

                                            hostCubit.save(true);
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: Text(AppLocalizations.of(
                                                  dialogContext)!
                                              .warning_different_covering_current),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsMenu(BuildContext context, HomeState state) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 1:
            // Import functionality
            await importHostsDialog(context, state.data.hostFiles,
                onImportSuccess: () {
              context.read<HomeCubit>().refreshHostFiles(context);
            });
            break;
          case 2:
            // Export functionality
            await exportHostsDialog(context, state.data.hostFiles);
            break;
          case 3:
            // Remote sync functionality
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServerSettingsPage(),
              ),
            );

            context.read<HomeCubit>().refreshHostFiles(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                const Icon(Icons.file_upload),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.import),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                const Icon(Icons.file_download),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.export),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 3,
            child: Row(
              children: [
                const Icon(Icons.cloud_sync),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.remote_sync),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget buildMoreButton(SimpleHostFile hostFile) {
    if (hostFile.fileName == "system") {
      return const SizedBox();
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return _buildHostFileOptionsMenu(context, hostFile);
      },
    );
  }

  Widget _buildHostFileOptionsMenu(
      BuildContext context, SimpleHostFile hostFile) {
    final homeCubit = context.read<HomeCubit>();

    return PopupMenuButton<int>(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
      ),
      onSelected: (value) async {
        switch (value) {
          case 1:
            String result =
                (await hostConfigDialog(context, hostFile.remark) ?? "");
            if (result.isEmpty) return;
            homeCubit.updateHostFileRemark(hostFile.fileName, result);
            break;
          case 2:
            deleteMultiple(context, [hostFile.remark], () async {
              homeCubit.deleteHostFile(hostFile.fileName);
            });
            break;
          case 3:
            final FileManager fileManager = FileManager();
            final bool success = await fileManager.exportMultipleHostFiles(
                [hostFile], AppLocalizations.of(context)!.export_data);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.export_success)),
              );
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {
            "icon": Icons.edit,
            "text": AppLocalizations.of(context)!.edit,
            "value": 1
          },
          {
            "icon": Icons.file_download,
            "text": AppLocalizations.of(context)!.export,
            "value": 3
          },
          {
            "icon": Icons.delete_outline,
            "text": AppLocalizations.of(context)!.remove,
            "value": 2
          },
        ];

        return list.map((item) {
          return PopupMenuItem<int>(
            value: int.parse(item["value"].toString()),
            child: Row(
              children: [
                Icon(item["icon"]! as IconData),
                const SizedBox(width: 8),
                Text(item["text"]!.toString()),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
