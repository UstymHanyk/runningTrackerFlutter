import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/services/connectivity_service.dart';

class HeartRateDashboardScreen extends StatefulWidget {
  const HeartRateDashboardScreen({super.key});

  @override
  State<HeartRateDashboardScreen> createState() => _HeartRateDashboardScreenState();
}

class _HeartRateDashboardScreenState extends State<HeartRateDashboardScreen> {
  late MqttService _mqttService;
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService();
    _connectivityService = context.read<ConnectivityService>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMqtt();
    });
  }

  Future<void> _initializeMqtt() async {
    if (_connectivityService.isConnected) {
      await _mqttService.connect();
    } else {
      _showConnectivityDialog();
    }
  }

  void _showConnectivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_connectivityService.isConnected) {
                _initializeMqtt();
              }
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mqttService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Monitor'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              return Icon(
                connectivity.isConnected ? Icons.wifi : Icons.wifi_off,
                color: connectivity.isConnected ? Colors.green : Colors.red,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ConnectivityService>(
        builder: (context, connectivity, child) {
          return Column(
            children: [
              // Connectivity Status Banner
              if (!connectivity.isConnected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade100,
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Main Content
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: _mqttService,
                  child: Consumer<MqttService>(
                    builder: (context, mqttService, child) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Connection Status Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connection Status',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          mqttService.isConnected 
                                              ? Icons.check_circle 
                                              : Icons.error,
                                          color: mqttService.isConnected 
                                              ? Colors.green 
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(mqttService.connectionStatus),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Device Status: ${mqttService.deviceStatus}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Heart Rate Display
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Heart Rate',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          mqttService.currentHeartRate.toInt().toString(),
                                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            color: _getHeartRateColor(mqttService.currentHeartRate),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'BPM',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _getHeartRateStatus(mqttService.currentHeartRate),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _getHeartRateColor(mqttService.currentHeartRate),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: connectivity.isConnected && !mqttService.isConnected
                                        ? () => _mqttService.connect()
                                        : null,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reconnect'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: mqttService.isConnected
                                        ? () => _mqttService.disconnect()
                                        : null,
                                    icon: const Icon(Icons.stop),
                                    label: const Text('Disconnect'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getHeartRateColor(double heartRate) {
    if (heartRate == 0) return Colors.grey;
    if (heartRate < 60) return Colors.blue;
    if (heartRate <= 100) return Colors.green;
    if (heartRate <= 150) return Colors.orange;
    return Colors.red;
  }

  String _getHeartRateStatus(double heartRate) {
    if (heartRate == 0) return 'No data';
    if (heartRate < 60) return 'Low';
    if (heartRate <= 100) return 'Normal';
    if (heartRate <= 150) return 'Elevated';
    return 'High';
  }
} 