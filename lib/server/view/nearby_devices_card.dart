import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        print(state.devices);
        return Card(
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
                  ...state.devices
                      .map((device) => _buildDeviceItem(context, device))
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Stack(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
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
                    Text(
                      device.ip,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: device.isOnline ? null : Colors.grey,
                      ),
                    ),
                    if (!device.isOnline) ...[
                      const SizedBox(width: 8),
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
                  ],
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
                // 显示最后见到时间
                Text(
                  '最后见到: ${device.lastSeen.formatLastSeen()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: device.hasSharing && device.isOnline
                ? () {
                    context
                        .read<NearbyDevicesCubit>()
                        .toggleDeviceSelection(device);
                    Navigator.pop(context);
                  }
                : null,
            tooltip: AppLocalizations.of(context)!.visit_device,
          )
        ],
      ),
    );
  }
}
