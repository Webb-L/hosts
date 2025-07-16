import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hosts/utils/nearby_devices_scanner.dart';

part 'nearby_devices_state.dart';

/// 附近设备 Cubit
class NearbyDevicesCubit extends Cubit<NearbyDevicesState> {
  NearbyDevicesCubit() : super(const NearbyDevicesInitial(NearbyDevicesStateData()));

  /// 加载缓存的设备
  Future<void> loadCachedDevices() async {
    try {
      emit(NearbyDevicesLoading(
        state.data.copyWith(isLoading: true, errorMessage: null),
      ));
      
      final cachedDevices = await NearbyDevicesScanner.getCachedDevices();
      
      emit(NearbyDevicesInitial(
        state.data.copyWith(
          isLoading: false,
          devices: cachedDevices,
        ),
      ));
      
      // 如果有缓存设备，自动检查在线状态
      if (cachedDevices.isNotEmpty) {
        checkDevicesOnlineStatus();
      }
    } catch (e) {
      emit(NearbyDevicesError(
        state.data.copyWith(
          isLoading: false,
          errorMessage: '加载缓存设备失败: $e',
        ),
      ));
    }
  }

  /// 扫描附近设备
  Future<void> scanNearbyDevices() async {
    try {
      emit(NearbyDevicesScanning(
        state.data.copyWith(
          isScanning: true,
          errorMessage: null,
          devices: [], // 清空现有设备列表
        ),
      ));

      // 开始实时扫描
      await NearbyDevicesScanner.scanNearbyDevicesRealTime(
        onDeviceFound: (device) {
          // 实时更新设备列表
          onDeviceFound(device);
        },
      );

      emit(NearbyDevicesSuccess(
        state.data.copyWith(
          isScanning: false,
          successMessage: '扫描完成，发现${state.devices.length}个设备',
        ),
      ));
    } catch (e) {
      emit(NearbyDevicesError(
        state.data.copyWith(
          isScanning: false,
          errorMessage: '扫描附近设备失败: $e',
        ),
      ));
    }
  }

  /// 检查设备在线状态
  Future<void> checkDevicesOnlineStatus() async {
    if (state.devices.isEmpty) return;

    try {
      emit(NearbyDevicesCheckingStatus(
        state.data.copyWith(isCheckingStatus: true, errorMessage: null),
      ));

      await NearbyDevicesScanner.checkCachedDevicesOnlineStatus();

      // 重新加载更新后的设备列表
      final updatedDevices = await NearbyDevicesScanner.getCachedDevices();
      
      emit(NearbyDevicesInitial(
        state.data.copyWith(
          isCheckingStatus: false,
          devices: updatedDevices,
        ),
      ));
    } catch (e) {
      emit(NearbyDevicesError(
        state.data.copyWith(
          isCheckingStatus: false,
          errorMessage: '检查设备在线状态失败: $e',
        ),
      ));
    }
  }

  /// 清除设备缓存
  Future<void> clearDeviceCache() async {
    try {
      await NearbyDevicesScanner.clearCache();
      
      emit(NearbyDevicesSuccess(
        state.data.copyWith(
          devices: [],
          successMessage: '设备缓存已清除',
        ),
      ));
    } catch (e) {
      emit(NearbyDevicesError(
        state.data.copyWith(
          errorMessage: '清除设备缓存失败: $e',
        ),
      ));
    }
  }

  /// 设备发现处理
  void onDeviceFound(NearbyDevice device) {
    final updatedDevices = List<NearbyDevice>.from(state.devices);
    
    // 避免重复添加同一IP的设备
    final existingIndex = updatedDevices.indexWhere((d) => d.ip == device.ip);
    if (existingIndex >= 0) {
      updatedDevices[existingIndex] = device;
    } else {
      updatedDevices.add(device);
    }
    
    emit(NearbyDevicesDeviceFound(
      state.data.copyWith(devices: updatedDevices),
    ));
  }

  /// 选择设备
  void selectDevice(NearbyDevice? device) {
    emit(NearbyDevicesSelectionChanged(
      state.data.copyWith(
        selectedDevice: device,
        clearSelectedDevice: device == null,
      ),
    ));
  }
  
  /// 切换设备选择状态
  void toggleDeviceSelection(NearbyDevice device) {
    if (state.selectedDevice?.ip == device.ip) {
      // 如果已选中，则取消选择
      selectDevice(null);
    } else {
      // 否则选择该设备
      selectDevice(device);
    }
  }
  
  /// 检查设备是否被选中
  bool isDeviceSelected(NearbyDevice device) {
    return state.selectedDevice?.ip == device.ip;
  }

  /// 获取设备状态摘要（供其他组件使用）
  Map<String, int> getDevicesSummary() {
    return {
      'total': state.data.totalDevicesCount,
      'online': state.data.onlineDevicesCount,
      'offline': state.data.totalDevicesCount - state.data.onlineDevicesCount,
    };
  }

  /// 清除消息
  void clearMessages() {
    emit(NearbyDevicesInitial(
      state.data.copyWith(
        errorMessage: null,
        successMessage: null,
      ),
    ));
  }
}