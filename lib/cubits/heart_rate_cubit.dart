import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/services/connectivity_service.dart';

part 'heart_rate_state.dart';

class HeartRateCubit extends Cubit<HeartRateState> {
  final MqttService _mqttService;
  final ConnectivityService _connectivityService;

  HeartRateCubit(this._mqttService, this._connectivityService) : super(HeartRateInitial());

  void initialize() {
    // Listen to MQTT service changes
    _mqttService.addListener(_onMqttServiceChanged);
    
    if (_connectivityService.isConnected) {
      connect();
    } else {
      emit(HeartRateNoConnection());
    }
  }

  void _onMqttServiceChanged() {
    if (_mqttService.isConnected) {
      emit(HeartRateConnected(
        currentHeartRate: _mqttService.currentHeartRate,
        connectionStatus: _mqttService.connectionStatus,
        deviceStatus: _mqttService.deviceStatus,
      ));
    } else {
      emit(HeartRateDisconnected(_mqttService.connectionStatus));
    }
  }

  Future<void> connect() async {
    if (!_connectivityService.isConnected) {
      emit(HeartRateNoConnection());
      return;
    }

    emit(HeartRateConnecting());
    try {
      await _mqttService.connect();
      // State will be updated via listener
    } catch (e) {
      emit(HeartRateError('Connection failed: $e'));
    }
  }

  Future<void> disconnect() async {
    try {
      _mqttService.disconnect();
      emit(const HeartRateDisconnected('Manually disconnected'));
    } catch (e) {
      emit(HeartRateError('Disconnect failed: $e'));
    }
  }

  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    connect();
  }

  void dispose() {
    _mqttService.removeListener(_onMqttServiceChanged);
    _mqttService.dispose();
    super.close();
  }

  // Helper methods for UI
  String getHeartRateStatus(double heartRate) {
    if (heartRate == 0) return 'No data';
    if (heartRate < 60) return 'Low';
    if (heartRate <= 100) return 'Normal';
    if (heartRate <= 150) return 'Elevated';
    return 'High';
  }

  Color getHeartRateColor(double heartRate) {
    if (heartRate == 0) return const Color(0xFF9E9E9E); // Colors.grey
    if (heartRate < 60) return const Color(0xFF2196F3); // Colors.blue
    if (heartRate <= 100) return const Color(0xFF4CAF50); // Colors.green
    if (heartRate <= 150) return const Color(0xFFFF9800); // Colors.orange
    return const Color(0xFFF44336); // Colors.red
  }
} 