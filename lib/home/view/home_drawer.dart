import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/widget/dialog/dialog.dart';
import 'package:hosts/widget/snakbar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Drawer(
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
                    const Expanded(child: SizedBox()),
                    IconButton(
                        onPressed: () async {
                          String? remark = await hostConfigDialog(context);
                          if (remark == null || remark.isEmpty) return;
                          context.read<HomeCubit>().addHostFile(remark);
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.data.hostFiles.length,
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
                        onPressed:
                            state.data.useHostFiles.contains(hostFile.fileName)
                                ? null
                                : () async {
                                    // final String path = await _fileManager
                                    //     .getHostsFilePath(hostFile.fileName);
                                    //
                                    // if (!await widget
                                    //     .onClickUse(File(path).readAsStringSync())) {
                                    //   return;
                                    // }

                                    // setState(() {
                                    //   useHostFile = hostFile.fileName;
                                    // });
                                    // _settingsManager.setString(
                                    //     settingKeyUseHostFile, hostFile.fileName);
                                  },
                        icon: Icon(
                            state.data.useHostFiles.contains(hostFile.fileName)
                                ? Icons.star
                                : Icons.star_border),
                      ),
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      selected: state.data.selectHostFile == hostFile.fileName,
                      trailing: buildMoreButton(hostFile),
                      onTap: () {
                        if (state.data.selectHostFile == hostFile.fileName) {
                          return;
                        }
                        if (!context.read<HostCubit>().state.data.isSave) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  AppLocalizations.of(context)!.error_not_save),
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

                        context.read<HomeCubit>().selectHost(hostFile.fileName);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildMoreButton(SimpleHostFile hostFile) {
    if (hostFile.fileName == "system") {
      return const SizedBox();
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
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
                  // 判断是否删除使用的 Host 文件
                  // final bool isDeleteUse = list
                  //     .where(
                  //         (host) => state.useHostFiles.contains(host.fileName))
                  //     .isNotEmpty;
                  // 判断是否删除选择的 Host 文件
                  // final bool isDeleteSelect = list
                  //     .where((host) => state.selectHostFile == host.fileName)
                  //     .isNotEmpty;
                  //
                  // if (isDeleteUse) {
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
                  // }
                  //
                  // if (isDeleteSelect) {
                  //   homeCubit.selectHost("system");
                  // }

                  // homeCubit.deleteHostFile(hostFile.fileName);
                  //
                  // setState(() {
                  //   hostFiles.removeWhere((hostFile) => list.contains(hostFile));
                  // });
                  // await _settingsManager.setList(settingKeyHostConfigs, hostFiles);
                  // widget.onChanged(
                  //     await _fileManager.getHostsFilePath(selectHostFile!),
                  //     selectHostFile!);
                  // _fileManager
                  //     .deleteFiles(list.map((file) => file.fileName).toList());
                });
                break;
              case 3:
                final FileManager fileManager = FileManager();
                final bool success = await fileManager.exportHostFile(
                  hostFile, 
                  AppLocalizations.of(context)!.export_data
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.export_success)),
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
                "icon": Icons.delete_outline,
                "text": AppLocalizations.of(context)!.remove,
                "value": 2
              },
              {
                "icon": Icons.file_download,
                "text": AppLocalizations.of(context)!.export,
                "value": 3
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
      },
    );
  }
}
