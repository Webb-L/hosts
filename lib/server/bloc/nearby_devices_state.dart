part of 'nearby_devices_cubit.dart';

/// 附近设备状态数据类
/// 保存所有与附近设备相关的状态属性
class NearbyDevicesStateData {
  /// 设备列表
  final List<NearbyDevice> devices;
  
  /// 是否正在扫描
  final bool isScanning;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final String? errorMessage;

  /// 构造函数
  const NearbyDevicesStateData({
    this.devices = const [],
    this.isScanning = false,
    this.isLoading = false,
    this.errorMessage,
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
    bool? isScanning,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NearbyDevicesStateData(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
  
  /// 是否正在扫描
  bool get isScanning => data.isScanning;
  
  /// 是否正在加载
  bool get isLoading => data.isLoading;
  
  /// 错误信息
  String? get errorMessage => data.errorMessage;
}

/// 初始状态
class NearbyDevicesInitial extends NearbyDevicesState {
  const NearbyDevicesInitial(super.data);
}

/// 扫描中状态
class NearbyDevicesScanning extends NearbyDevicesState {
  const NearbyDevicesScanning(super.data);
}

/// 加载中状态
class NearbyDevicesLoading extends NearbyDevicesState {
  const NearbyDevicesLoading(super.data);
}

/// 设备发现状态
class NearbyDevicesDeviceFound extends NearbyDevicesState {
  const NearbyDevicesDeviceFound(super.data);
}

/// 错误状态
class NearbyDevicesError extends NearbyDevicesState {
  const NearbyDevicesError(super.data);
}