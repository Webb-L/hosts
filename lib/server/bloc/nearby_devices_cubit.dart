import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hosts/utils/nearby_devices_scanner.dart';

part 'nearby_devices_state.dart';

/// 附近设备 Cubit
class NearbyDevicesCubit extends Cubit<NearbyDevicesState> {
  NearbyDevicesCubit() : super(const NearbyDevicesInitial(NearbyDevicesStateData()));

  /// 扫描附近设备
  Future<void> scanNearbyDevices() async {
    try {
      if (isClosed) return;
      
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
          if (!isClosed) {
            onDeviceFound(device);
          }
        },
      );

      if (!isClosed) {
        emit(NearbyDevicesInitial(
          state.data.copyWith(
            isScanning: false,
          ),
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(NearbyDevicesError(
          state.data.copyWith(
            isScanning: false,
            errorMessage: 'Failed to scan nearby devices: $e',
          ),
        ));
      }
    }
  }

  /// 设备发现处理
  void onDeviceFound(NearbyDevice device) {
    if (isClosed) return;
    
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
    if (isClosed) return;
    
    emit(NearbyDevicesInitial(
      state.data.copyWith(
        errorMessage: null,
      ),
    ));
  }
}