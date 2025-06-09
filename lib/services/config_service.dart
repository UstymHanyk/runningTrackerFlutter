import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _brokerUrlKey = 'mqtt_broker_url';
  static const String _brokerPortKey = 'mqtt_broker_port';
  
  static const String defaultBrokerUrl = 'broker.hivemq.com';
  static const int defaultBrokerPort = 1883;
  
  static Future<String> getBrokerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_brokerUrlKey) ?? defaultBrokerUrl;
  }
  
  static Future<int> getBrokerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_brokerPortKey) ?? defaultBrokerPort;
  }
  
  static Future<void> setBrokerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brokerUrlKey, url);
  }
  
  static Future<void> setBrokerPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brokerPortKey, port);
  }
  
  static Future<void> saveConfiguration(String url, int port) async {
    await Future.wait([
      setBrokerUrl(url),
      setBrokerPort(port),
    ]);
  }
} 