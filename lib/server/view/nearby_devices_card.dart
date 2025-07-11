import 'package:flutter/material.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/utils/nearby_devices_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

/// 附近设备卡片组件
class NearbyDevicesCard extends StatefulWidget {
  const NearbyDevicesCard({super.key});

  @override
  State<NearbyDevicesCard> createState() => _NearbyDevicesCardState();
}

class _NearbyDevicesCardState extends State<NearbyDevicesCard> {
  List<NearbyDevice> _nearbyDevices = [];
  bool _isScanning = false;

  /// 扫描附近设备
  Future<void> _scanNearbyDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // 首先测试本地服务器是否正在运行
      final bool localServerRunning = await NearbyDevicesScanner.testLocalServer();
      if (!localServerRunning) {
        print('本地服务器未运行，无法扫描其他设备');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('请先启动本地服务器再扫描附近设备'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() {
          _nearbyDevices = [];
        });
        return;
      }
      
      final devices = await NearbyDevicesScanner.scanNearbyDevices();
      setState(() {
        _nearbyDevices = devices;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('扫描完成，发现${devices.length}个设备'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      print('扫描附近设备失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('扫描失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// 启动设备URL
  Future<void> _launchDeviceUrl(String ip) async {
    final url = 'http://$ip:1204';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('无法打开URL: $url'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开设备失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 构建设备项
  Widget _buildDeviceItem(NearbyDevice device) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            device.hasSharing ? Icons.share : Icons.computer,
            color: device.hasSharing ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.ip,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  device.hasSharing 
                      ? AppLocalizations.of(context)!.sharing_enabled
                      : AppLocalizations.of(context)!.device_reachable,
                  style: TextStyle(
                    fontSize: 12,
                    color: device.hasSharing ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (device.hasSharing)
            IconButton(
              icon: const Icon(Icons.launch),
              onPressed: () => _launchDeviceUrl(device.ip),
              tooltip: AppLocalizations.of(context)!.visit_device,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isScanning ? null : _scanNearbyDevices,
                  tooltip: AppLocalizations.of(context)!.scan_nearby_devices,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_nearbyDevices.isEmpty && !_isScanning)
              Text(
                AppLocalizations.of(context)!.no_nearby_devices,
                style: const TextStyle(color: Colors.grey),
              )
            else if (_nearbyDevices.isNotEmpty)
              ..._nearbyDevices.map((device) => _buildDeviceItem(device))
            else
              Text(
                AppLocalizations.of(context)!.scanning_devices,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}