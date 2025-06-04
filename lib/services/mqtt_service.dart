import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService extends ChangeNotifier {
  static const String _brokerUrl = 'broker.hivemq.com';
  static const int _brokerPort = 1883;
  static const String _heartRateTopic = 'esp8266/heartrate';
  static const String _statusTopic = 'esp8266/status';
  
  MqttServerClient? _client;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  double _currentHeartRate = 0.0;
  String _deviceStatus = 'Unknown';
  
  // Getters
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  double get currentHeartRate => _currentHeartRate;
  String get deviceStatus => _deviceStatus;

  Future<void> connect() async {
    try {
      final clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient(_brokerUrl, clientId);
      
      _client!.port = _brokerPort;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.pongCallback = _pong;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillTopic('clients/flutter_client')
          .withWillMessage('Flutter client disconnected unexpectedly')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      _client!.connectionMessage = connMessage;

      _connectionStatus = 'Connecting...';
      notifyListeners();

      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
      _connectionStatus = 'Connection failed: ${e.toString()}';
      _isConnected = false;
      notifyListeners();
      _client?.disconnect();
    }
  }

  void _onConnected() {
    debugPrint('MQTT Connected to broker');
    _isConnected = true;
    _connectionStatus = 'Connected';
    notifyListeners();
    
    // Subscribe to topics
    _subscribeToTopics();
  }

  void _onDisconnected() {
    debugPrint('MQTT Disconnected from broker');
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    _currentHeartRate = 0.0;
    _deviceStatus = 'Disconnected';
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to topic: $topic');
  }

  void _pong() {
    debugPrint('MQTT Ping response received');
  }

  void _subscribeToTopics() {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(_heartRateTopic, MqttQos.atMostOnce);
      _client!.subscribe(_statusTopic, MqttQos.atMostOnce);
      
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final topic = messages[0].topic;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        _handleMessage(topic, payload);
      });
    }
  }

  void _handleMessage(String topic, String payload) {
    debugPrint('Received message on topic $topic: $payload');
    
    try {
      if (topic == _heartRateTopic) {
        _currentHeartRate = double.tryParse(payload) ?? 0.0;
      } else if (topic == _statusTopic) {
        _deviceStatus = payload;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void publishMessage(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      debugPrint('Published message to $topic: $message');
    }
  }

  void disconnect() {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
} 