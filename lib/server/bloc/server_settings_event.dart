import 'package:equatable/equatable.dart';
import 'package:hosts/model/simple_host_file.dart';

/// 服务器设置页面事件
abstract class ServerSettingsEvent extends Equatable {
  const ServerSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载服务器设置
class LoadServerSettings extends ServerSettingsEvent {}

/// 加载网络接口
class LoadNetworkInterfaces extends ServerSettingsEvent {}

/// 切换服务器状态
class ToggleServerStatus extends ServerSettingsEvent {}

/// 启动服务器
class StartServer extends ServerSettingsEvent {
  final List<SimpleHostFile>? selectedHosts;
  
  const StartServer(this.selectedHosts);
  
  @override
  List<Object?> get props => [selectedHosts];
}

/// 停止服务器
class StopServer extends ServerSettingsEvent {}

/// 刷新服务器状态
class RefreshServerStatus extends ServerSettingsEvent {}