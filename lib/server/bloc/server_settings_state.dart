import 'package:equatable/equatable.dart';

/// 服务器设置页面状态
class ServerSettingsState extends Equatable {
  const ServerSettingsState({
    this.isLoading = true,
    this.isServerEnabled = false,
    this.serverStatus,
    this.networkInterfaces = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isServerEnabled;
  final Map<String, dynamic>? serverStatus;
  final List<Map<String, String>> networkInterfaces;
  final String? errorMessage;

  ServerSettingsState copyWith({
    bool? isLoading,
    bool? isServerEnabled,
    Map<String, dynamic>? serverStatus,
    List<Map<String, String>>? networkInterfaces,
    String? errorMessage,
  }) {
    return ServerSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isServerEnabled: isServerEnabled ?? this.isServerEnabled,
      serverStatus: serverStatus ?? this.serverStatus,
      networkInterfaces: networkInterfaces ?? this.networkInterfaces,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isServerEnabled,
        serverStatus,
        networkInterfaces,
        errorMessage,
      ];
}