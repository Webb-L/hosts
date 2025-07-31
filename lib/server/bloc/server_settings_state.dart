import 'package:equatable/equatable.dart';

/// 服务器设置页面状态
class ServerSettingsState extends Equatable {
  const ServerSettingsState({
    this.isLoading = true,
    this.isServerEnabled = false,
    this.serverStatus,
    this.networkInterfaces = const [],
    this.errorMessage,
    this.isAutoStartEnabled = false,
  });

  final bool isLoading;
  final bool isServerEnabled;
  final Map<String, dynamic>? serverStatus;
  final List<Map<String, String>> networkInterfaces;
  final String? errorMessage;
  final bool isAutoStartEnabled;

  ServerSettingsState copyWith({
    bool? isLoading,
    bool? isServerEnabled,
    Map<String, dynamic>? serverStatus,
    List<Map<String, String>>? networkInterfaces,
    String? errorMessage,
    bool? isAutoStartEnabled,
  }) {
    return ServerSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isServerEnabled: isServerEnabled ?? this.isServerEnabled,
      serverStatus: serverStatus ?? this.serverStatus,
      networkInterfaces: networkInterfaces ?? this.networkInterfaces,
      errorMessage: errorMessage,
      isAutoStartEnabled: isAutoStartEnabled ?? this.isAutoStartEnabled,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isServerEnabled,
        serverStatus,
        networkInterfaces,
        errorMessage,
        isAutoStartEnabled,
      ];
}