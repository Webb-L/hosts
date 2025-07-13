part of 'nearby_devices_cubit.dart';

/// 附近设备状态
class NearbyDevicesState {
  const NearbyDevicesState({
    this.devices = const [],
    this.selectedDevice,
    this.isScanning = false,
    this.isCheckingStatus = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<NearbyDevice> devices;
  final NearbyDevice? selectedDevice;
  final bool isScanning;
  final bool isCheckingStatus;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  /// 获取在线设备数量
  int get onlineDevicesCount => devices.where((device) => device.isOnline).length;
  
  /// 获取总设备数量
  int get totalDevicesCount => devices.length;
  
  /// 获取在线设备列表
  List<NearbyDevice> get onlineDevices => devices.where((device) => device.isOnline).toList();
  
  /// 获取离线设备列表
  List<NearbyDevice> get offlineDevices => devices.where((device) => !device.isOnline).toList();

  NearbyDevicesState copyWith({
    List<NearbyDevice>? devices,
    NearbyDevice? selectedDevice,
    bool clearSelectedDevice = false,
    bool? isScanning,
    bool? isCheckingStatus,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return NearbyDevicesState(
      devices: devices ?? this.devices,
      selectedDevice: clearSelectedDevice ? null : (selectedDevice ?? this.selectedDevice),
      isScanning: isScanning ?? this.isScanning,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

}