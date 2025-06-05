import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:my_project/cubits/main_screen_cubit.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/widgets/main_screen/main_app_bar.dart';
import 'package:my_project/widgets/main_screen/connectivity_banner.dart';
import 'package:my_project/widgets/main_screen/current_run_display.dart';
import 'package:my_project/widgets/main_screen/run_input_section.dart';
import 'package:my_project/widgets/main_screen/run_history_section.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the cubit when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainScreenCubit>().initialize();
    });

    return Scaffold(
      appBar: const MainAppBar(),
      body: Consumer3<RunProviderInterface, ConnectivityService, AuthProviderInterface>(
        builder: (context, runProvider, connectivityService, authProvider, child) {
          return BlocListener<MainScreenCubit, MainScreenState>(
            listener: (context, state) {
              if (state is MainScreenError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Connectivity Status Banner
                  ConnectivityBanner(isConnected: connectivityService.isConnected),
                  
                  const SizedBox(height: 20),
                  
                  // Current Run Display
                  CurrentRunDisplay(
                    currentDistance: runProvider.currentDistance,
                    currentHeartRate: runProvider.currentHeartRate,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Run Input Section
                  RunInputSection(
                    currentDistance: runProvider.currentDistance,
                    isLoading: runProvider.isLoading,
                    error: runProvider.error,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Run History Section
                  RunHistorySection(
                    runs: runProvider.runs,
                    isLoading: runProvider.isLoading,
                    onDeleteRun: (runId) => runProvider.deleteRun(runId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Consumer<RunProviderInterface>(
          builder: (context, runProvider, child) {
            return FloatingActionButton.extended(
              onPressed: () => runProvider.incrementDistance(0.1),
              tooltip: 'Add 0.1 km',
              icon: const Icon(Icons.directions_run),
              label: const Text(
                "Run 0.1km",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}