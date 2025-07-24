import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/server/bloc/nearby_devices_cubit.dart';
import 'package:hosts/server/bloc/server_settings_bloc.dart';
import 'package:hosts/server/bloc/server_settings_event.dart';
import 'package:hosts/server/bloc/server_settings_state.dart';
import 'package:hosts/server/view/nearby_devices_card.dart';
import 'package:hosts/server/view/server_status_card.dart';

/// 服务器设置页面
class ServerSettingsPage extends StatelessWidget {
  const ServerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServerSettingsBloc()
            ..add(LoadServerSettings())
            ..add(LoadNetworkInterfaces()),
        ),
        BlocProvider(
          create: (context) => NearbyDevicesCubit(),
        ),
      ],
      child: const _ServerSettingsView(),
    );
  }
}

class _ServerSettingsView extends StatelessWidget {
  const _ServerSettingsView();

  // 使用 GlobalKey 保持组件状态
  static final GlobalKey _nearbyDevicesKey = GlobalKey();
  static final GlobalKey _serverStatusKey = GlobalKey();
  static final GlobalKey _apiDocsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.remote_sync),
      ),
      body: BlocConsumer<ServerSettingsBloc, ServerSettingsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.serverStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildResponsiveLayout(context, state),
          );
        },
      ),
    );
  }

  /// 构建响应式布局
  Widget _buildResponsiveLayout(
      BuildContext context, ServerSettingsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 判断是否为大屏幕 (宽度大于 800px 认为是大屏)
        final bool isLargeScreen = constraints.maxWidth > 800;

        if (isLargeScreen) {
          // 大屏布局：上排两列，下排全宽
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上排：服务状态和API文档并排
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左侧：服务器状态卡片
                    Expanded(
                      flex: 1,
                      child: _buildStatusCard(context, state),
                    ),
                    const SizedBox(width: 16),
                    // 右侧：API文档卡片
                    Expanded(
                      flex: 1,
                      child: _buildApiDocsCard(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 下排：附近设备卡片（全宽）
              NearbyDevicesCard(key: _nearbyDevicesKey),
            ],
          );
        } else {
          // 小屏布局：垂直排列
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务器状态卡片
              _buildStatusCard(context, state),
              const SizedBox(height: 16),
              // 附近设备卡片
              NearbyDevicesCard(key: _nearbyDevicesKey),
              const SizedBox(height: 16),
              // API文档卡片
              _buildApiDocsCard(context),
            ],
          );
        }
      },
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard(BuildContext context, ServerSettingsState state) {
    return ServerStatusCard(
      key: _serverStatusKey,
      serverStatus: state.serverStatus,
      networkInterfaces: state.networkInterfaces,
      onStartServer: (selectedHosts) {
        context.read<ServerSettingsBloc>().add(StartServer(selectedHosts));
      },
      onStopServer: () {
        context.read<ServerSettingsBloc>().add(StopServer());
      },
      isAutoStartEnabled: state.isAutoStartEnabled,
      onAutoStartChanged: (enabled, selectedHosts) {
        context.read<ServerSettingsBloc>().add(
          UpdateAutoStartSettings(enabled, selectedHosts),
        );
      },
    );
  }

  /// 构建API文档卡片
  Widget _buildApiDocsCard(BuildContext context) {
    return Card(
      key: _apiDocsKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.api_docs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.api_endpoints}：',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildApiEndpoint(context, 'GET', '/',
                AppLocalizations.of(context)!.server_status),
            _buildApiEndpoint(context, 'GET', '/api/hosts',
                AppLocalizations.of(context)!.get_all_hosts_files),
            _buildApiEndpoint(context, 'GET', '/api/hosts/{fileName}',
                AppLocalizations.of(context)!.get_specific_hosts_file),
            _buildApiEndpoint(context, 'GET', '/api/hosts/{fileName}/history',
                AppLocalizations.of(context)!.get_hosts_file_history),
            _buildApiEndpoint(
                context,
                'GET',
                '/api/hosts/{fileName}/history/{historyId}',
                AppLocalizations.of(context)!.get_specific_history_content),
          ],
        ),
      ),
    );
  }

  /// 构建API端点项
  Widget _buildApiEndpoint(
      BuildContext context, String method, String path, String description) {
    Color methodColor;
    switch (method) {
      case 'GET':
        methodColor = Theme.of(context).colorScheme.primary;
        break;
      case 'POST':
        methodColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'PUT':
        methodColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'DELETE':
        methodColor = Theme.of(context).colorScheme.error;
        break;
      default:
        methodColor = Theme.of(context).colorScheme.outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: methodColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
