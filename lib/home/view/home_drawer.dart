import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/server/bloc/nearby_devices_cubit.dart';
import 'package:hosts/server/view/server_settings_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/utils/nearby_devices_scanner.dart';
import 'package:hosts/widget/dialog/dialog.dart';
import 'package:hosts/widget/dialog/export_hosts_dialog.dart';
import 'package:hosts/widget/dialog/import_hosts_dialog.dart';
import 'package:hosts/widget/snakbar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    NearbyDevice? selectedDevice;

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
                      BlocBuilder<NearbyDevicesCubit, NearbyDevicesState>(
                        builder: (context, state) {
                          // print(state.devices);
                          if (state is NearbyDevicesSelectionChanged) {
                            if (state.selectedDevice != null) {
                              if (selectedDevice != state.selectedDevice) {
                                context.read<HomeCubit>().loadRemoteHostFiles(
                                      context,
                                      state.selectedDevice!,
                                    );
                              }
                            } else {
                              context.read<HomeCubit>().loadHostFiles(context);
                            }

                            selectedDevice = state.selectedDevice;
                          }

                          if (state.devices.isEmpty) {
                            return Text(
                              AppLocalizations.of(context)!.app_name,
                              style: Theme.of(context).textTheme.titleLarge,
                            );
                          }
                          return PopupMenuButton<String>(
                            onSelected: (value) {
                              // 只处理设备点击，不添加其他功能
                              if (value.startsWith('device_')) {
                                final ip = value.substring(7);
                                final device =
                                    state.devices.firstWhere((d) => d.ip == ip);
                                context
                                    .read<NearbyDevicesCubit>()
                                    .toggleDeviceSelection(device);

                                return;
                              }

                              context
                                  .read<NearbyDevicesCubit>()
                                  .selectDevice(null);
                            },
                            itemBuilder: (BuildContext context) {
                              final List<PopupMenuEntry<String>> items = [];
                              items.add(
                                const PopupMenuItem<String>(
                                  value: "local",
                                  child: Text('本地'),
                                ),
                              );
                              // 只显示设备列表
                              for (final device in state.devices) {
                                items.add(
                                  PopupMenuItem<String>(
                                    value: 'device_${device.ip}',
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Icon(
                                              device.hasSharing
                                                  ? Icons.share
                                                  : Icons.computer,
                                              color: device.isOnline
                                                  ? (device.hasSharing
                                                      ? Colors.green
                                                      : Colors.orange)
                                                  : Colors.grey,
                                              size: 20,
                                            ),
                                            if (device.isOnline)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                device.ip,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: device.isOnline
                                                      ? null
                                                      : Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                device.isOnline
                                                    ? (device.hasSharing
                                                        ? '可访问'
                                                        : '在线')
                                                    : '离线',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: device.isOnline
                                                      ? (device.hasSharing
                                                          ? Colors.green
                                                          : Colors.orange)
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (device.hasSharing &&
                                            device.isOnline)
                                          Icon(
                                            state.selectedDevice?.ip ==
                                                    device.ip
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            size: 16,
                                            color: state.selectedDevice?.ip ==
                                                    device.ip
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return items;
                            },
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.app_name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      state.selectedDevice?.ip ?? "本地",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          );
                        },
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () async {
                            String? remark = await hostConfigDialog(context);
                            if (remark == null || remark.isEmpty) return;
                            context.read<HomeCubit>().addHostFile(remark);
                          },
                          icon: const Icon(Icons.add)),
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          switch (value) {
                            case 1:
                              // Import functionality
                              await importHostsDialog(
                                  context, state.data.hostFiles,
                                  onImportSuccess: () {
                                context
                                    .read<HomeCubit>()
                                    .refreshHostFiles(context);
                              });
                              break;
                            case 2:
                              // Export functionality
                              await exportHostsDialog(
                                  context, state.data.hostFiles);
                              break;
                            case 3:
                              // Remote sync functionality
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServerSettingsPage(),
                                ),
                              );
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
                                  Text(AppLocalizations.of(context)!
                                      .remote_sync),
                                ],
                              ),
                            ),
                          ];
                        },
                      )
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
                        onTap: () {
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
