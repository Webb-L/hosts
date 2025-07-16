part of 'nearby_devices_cubit.dart';

/// 附近设备状态数据类
/// 保存所有与附近设备相关的状态属性
class NearbyDevicesStateData {
  /// 设备列表
  final List<NearbyDevice> devices;
  
  /// 当前选中的设备
  final NearbyDevice? selectedDevice;
  
  /// 是否正在扫描
  final bool isScanning;
  
  /// 是否正在检查状态
  final bool isCheckingStatus;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 成功信息
  final String? successMessage;

  /// 构造函数
  const NearbyDevicesStateData({
    this.devices = const [],
    this.selectedDevice,
    this.isScanning = false,
    this.isCheckingStatus = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// 获取在线设备数量
  int get onlineDevicesCount => devices.where((device) => device.isOnline).length;
  
  /// 获取总设备数量
  int get totalDevicesCount => devices.length;
  
  /// 获取在线设备列表
  List<NearbyDevice> get onlineDevices => devices.where((device) => device.isOnline).toList();
  
  /// 获取离线设备列表
  List<NearbyDevice> get offlineDevices => devices.where((device) => !device.isOnline).toList();

  /// 复制方法
  /// 用于基于当前状态创建新状态
  NearbyDevicesStateData copyWith({
    List<NearbyDevice>? devices,
    NearbyDevice? selectedDevice,
    bool clearSelectedDevice = false,
    bool? isScanning,
    bool? isCheckingStatus,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return NearbyDevicesStateData(
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

/// 附近设备状态基类
/// 使用密封类设计模式限制状态类型
/// 不可变状态基类
@immutable
sealed class NearbyDevicesState {
  final NearbyDevicesStateData data;

  const NearbyDevicesState(this.data);

  /// 获取在线设备数量
  int get onlineDevicesCount => data.onlineDevicesCount;
  
  /// 获取总设备数量
  int get totalDevicesCount => data.totalDevicesCount;
  
  /// 获取在线设备列表
  List<NearbyDevice> get onlineDevices => data.onlineDevices;
  
  /// 获取离线设备列表
  List<NearbyDevice> get offlineDevices => data.offlineDevices;

  /// 设备列表
  List<NearbyDevice> get devices => data.devices;
  
  /// 当前选中的设备
  NearbyDevice? get selectedDevice => data.selectedDevice;
  
  /// 是否正在扫描
  bool get isScanning => data.isScanning;
  
  /// 是否正在检查状态
  bool get isCheckingStatus => data.isCheckingStatus;
  
  /// 是否正在加载
  bool get isLoading => data.isLoading;
  
  /// 错误信息
  String? get errorMessage => data.errorMessage;
  
  /// 成功信息
  String? get successMessage => data.successMessage;
}

/// 初始状态
class NearbyDevicesInitial extends NearbyDevicesState {
  const NearbyDevicesInitial(super.data);
}

/// 扫描中状态
class NearbyDevicesScanning extends NearbyDevicesState {
  const NearbyDevicesScanning(super.data);
}

/// 检查状态中状态
class NearbyDevicesCheckingStatus extends NearbyDevicesState {
  const NearbyDevicesCheckingStatus(super.data);
}

/// 加载中状态
class NearbyDevicesLoading extends NearbyDevicesState {
  const NearbyDevicesLoading(super.data);
}

/// 设备发现状态
class NearbyDevicesDeviceFound extends NearbyDevicesState {
  const NearbyDevicesDeviceFound(super.data);
}

/// 设备选择变更状态
class NearbyDevicesSelectionChanged extends NearbyDevicesState {
  const NearbyDevicesSelectionChanged(super.data);
}

/// 错误状态
class NearbyDevicesError extends NearbyDevicesState {
  const NearbyDevicesError(super.data);
}

/// 成功状态
class NearbyDevicesSuccess extends NearbyDevicesState {
  const NearbyDevicesSuccess(super.data);
}