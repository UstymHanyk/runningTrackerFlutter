import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:my_project/cubits/heart_rate_cubit.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/widgets/heart_rate/connectivity_status_banner.dart';
import 'package:my_project/widgets/heart_rate/connection_status_card.dart';
import 'package:my_project/widgets/heart_rate/heart_rate_display_card.dart';
import 'package:my_project/widgets/heart_rate/action_buttons.dart';

class HeartRateDashboardScreen extends StatelessWidget {
  const HeartRateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the cubit when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeartRateCubit>().initialize();
    });

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
              ConnectivityStatusBanner(isConnected: connectivity.isConnected),
              
              // Main Content
              Expanded(
                child: BlocConsumer<HeartRateCubit, HeartRateState>(
                  listener: (context, state) {
                    if (state is HeartRateNoConnection) {
                      _showConnectivityDialog(context, connectivity);
                    } else if (state is HeartRateError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Connection Status Card
                          _buildConnectionStatusCard(state),
                          
                          const SizedBox(height: 16),
                          
                          // Heart Rate Display
                          _buildHeartRateCard(state),
                          
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          _buildActionButtons(state, connectivity.isConnected),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(HeartRateState state) {
    if (state is HeartRateConnected) {
      return ConnectionStatusCard(
        isConnected: true,
        connectionStatus: state.connectionStatus,
        deviceStatus: state.deviceStatus,
      );
    } else if (state is HeartRateDisconnected) {
      return ConnectionStatusCard(
        isConnected: false,
        connectionStatus: state.reason,
        deviceStatus: 'Disconnected',
      );
    } else if (state is HeartRateConnecting) {
      return const ConnectionStatusCard(
        isConnected: false,
        connectionStatus: 'Connecting...',
        deviceStatus: 'Connecting',
      );
    } else if (state is HeartRateError) {
      return ConnectionStatusCard(
        isConnected: false,
        connectionStatus: state.message,
        deviceStatus: 'Error',
      );
    } else {
      return const ConnectionStatusCard(
        isConnected: false,
        connectionStatus: 'Not connected',
        deviceStatus: 'Idle',
      );
    }
  }

  Widget _buildHeartRateCard(HeartRateState state) {
    double heartRate = 0.0;
    
    if (state is HeartRateConnected) {
      heartRate = state.currentHeartRate;
    }
    
    return HeartRateDisplayCard(heartRate: heartRate);
  }

  Widget _buildActionButtons(HeartRateState state, bool hasConnectivity) {
    bool isConnected = state is HeartRateConnected;
    
    return ActionButtons(
      isConnected: isConnected,
      hasConnectivity: hasConnectivity,
    );
  }

  void _showConnectivityDialog(BuildContext context, ConnectivityService connectivity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (connectivity.isConnected) {
                context.read<HeartRateCubit>().connect();
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
} 