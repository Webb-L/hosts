import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/server/bloc/nearby_devices_cubit.dart';
import 'package:hosts/utils/datetime_extensions.dart';
import 'package:hosts/utils/nearby_devices_scanner.dart';

/// 附近设备卡片组件
class NearbyDevicesCard extends StatelessWidget {
  const NearbyDevicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NearbyDevicesCubit, NearbyDevicesState>(
      listener: (context, state) {
        // 处理错误消息
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        // 处理成功消息
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.nearby_devices,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: state.isCheckingStatus
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.wifi_find),
                          onPressed:
                              state.devices.isEmpty || state.isCheckingStatus
                                  ? null
                                  : () => context
                                      .read<NearbyDevicesCubit>()
                                      .checkDevicesOnlineStatus(),
                          tooltip: '检查设备在线状态',
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_all),
                          onPressed: state.devices.isEmpty
                              ? null
                              : () => context
                                  .read<NearbyDevicesCubit>()
                                  .clearDeviceCache(),
                          tooltip: '清除设备缓存',
                        ),
                        IconButton(
                          icon: state.isScanning
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          onPressed: state.isScanning
                              ? null
                              : () => context
                                  .read<NearbyDevicesCubit>()
                                  .scanNearbyDevices(),
                          tooltip:
                              AppLocalizations.of(context)!.scan_nearby_devices,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.devices.isEmpty &&
                    !state.isScanning &&
                    !state.isLoading)
                  Text(
                    AppLocalizations.of(context)!.no_nearby_devices,
                    style: const TextStyle(color: Colors.grey),
                  )
                else if (state.devices.isNotEmpty)
                  _buildDeviceGrid(context, state.devices)
                else if (state.isScanning || state.isLoading)
                  Text(
                    state.isScanning
                        ? AppLocalizations.of(context)!.scanning_devices
                        : '加载中...',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建设备网格
  Widget _buildDeviceGrid(BuildContext context, List<NearbyDevice> devices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕宽度确定网格列数
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: StaggeredGrid.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: devices.map((device) {
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildDeviceItem(context, device),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// 构建设备项
  Widget _buildDeviceItem(BuildContext context, NearbyDevice device) {
    // 确定设备状态和颜色
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!device.isOnline) {
      statusColor = Colors.red;
      statusIcon = Icons.offline_bolt;
      statusText = '离线';
    } else if (device.hasSharing) {
      statusColor = Colors.green;
      statusIcon = Icons.share;
      statusText = AppLocalizations.of(context)!.sharing_enabled;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.computer;
      statusText = AppLocalizations.of(context)!.device_reachable;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 8,),
                Stack(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                    // 在线状态指示器
                    if (device.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.ip,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: device.isOnline ? null : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!device.isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '离线',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '最后见到: ${device.lastSeen.formatLastSeen()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (device.hasSharing && device.isOnline)
                  IconButton(
                    icon: const Icon(Icons.launch),
                    onPressed: () {
                      context
                          .read<NearbyDevicesCubit>()
                          .toggleDeviceSelection(device);
                      Navigator.pop(context);
                    },
                    tooltip: AppLocalizations.of(context)!.visit_device,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
