import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/widgets/run_list_item.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _runNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure we reload runs when the user changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRunsForCurrentUser();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also reload runs when dependencies change (like when returning from profile)
    _updateRunsForCurrentUser();
  }
  
  void _updateRunsForCurrentUser() {
    final authProvider = Provider.of<AuthProviderInterface>(context, listen: false);
    final runProvider = Provider.of<RunProviderInterface>(context, listen: false);
    
    // Check if user has changed and reload runs if needed
    if (authProvider.currentUser?.email != null) {
      runProvider.checkUserAndReload(authProvider.currentUser?.email);
    }
  }

  @override
  void dispose() {
    _runNameController.dispose();
    super.dispose();
  }

  void _handleInput(RunProviderInterface runProvider) {
    final String runName = _runNameController.text.trim();
    runProvider.saveRun(runName);
    _runNameController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showLogoutDialog() {
    // Capture the context that is valid for the initial dialog operations
    final BuildContext dialogBuildContext = context;

    showDialog(
      context: dialogBuildContext, // Use the captured context for showDialog
      builder: (BuildContext alertContext) => AlertDialog( // This is the context for the AlertDialog itself
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(alertContext).pop(), // Use alertContext to pop the alert
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Capture the AuthProvider and the Navigator from the MainScreen's context (dialogBuildContext)
              // before any async operations or dialog dismissal if they are needed after an async gap for logout.
              // However, for immediate navigation, MainScreen's context (dialogBuildContext or this.context) is fine.
              final AuthProviderInterface authProvider = dialogBuildContext.read<AuthProviderInterface>();
              final NavigatorState navigator = Navigator.of(dialogBuildContext);

              // Close the confirmation dialog first, using its own context (alertContext)
              Navigator.of(alertContext).pop();
              
              debugPrint('🔄 Logout button pressed, starting immediate navigation...');
              
              // Navigate immediately using the captured navigator
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
              
              debugPrint('✅ Navigation executed, now performing cleanup...');
              
              // Perform logout cleanup asynchronously after navigation
              Future.delayed(Duration.zero, () async {
                try {
                  // Use the captured authProvider for the logout operation
                  await authProvider.logout().timeout(
                    const Duration(seconds: 3),
                  );
                  debugPrint('✅ Logout cleanup completed');
                } catch (e) {
                  debugPrint('❌ Logout cleanup error: $e');
                }
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Running Tracker'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              return Icon(
                connectivity.isConnected ? Icons.wifi : Icons.wifi_off,
                color: connectivity.isConnected ? Colors.green : Colors.red,
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.monitor_heart),
            tooltip: 'Heart Rate Monitor',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.heartRateDashboard);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer3<RunProviderInterface, ConnectivityService, AuthProviderInterface>(
        builder: (context, runProvider, connectivityService, authProvider, child) {
          // Trigger run reload when auth state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.currentUser?.email != null) {
              runProvider.checkUserAndReload(authProvider.currentUser?.email);
            }
          });

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Connectivity Status Banner
                if (!connectivityService.isConnected)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16, top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Limited functionality - No internet connection',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
                const Text(
                  'CURRENT RUN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${runProvider.currentDistance.toStringAsFixed(1)} km',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                // Display Live Heart Rate if available and run is active
                if (runProvider.currentDistance > 0 && runProvider.currentHeartRate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${runProvider.currentHeartRate} bpm',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accent),
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _runNameController,
                  decoration: const InputDecoration(
                    labelText: "Enter run name (optional)",
                    hintText: 'e.g., Morning Jog'
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: runProvider.isLoading || runProvider.currentDistance <= 0
                      ? null
                      : () => _handleInput(runProvider),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: runProvider.currentDistance > 0 ? AppColors.accent : AppColors.surfaceSecondary,
                      foregroundColor: AppColors.textPrimary,
                  ),
                  child: runProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save Current Run"),
                ),
                if (runProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      runProvider.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  "RUN HISTORY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: runProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : runProvider.runs.isEmpty
                          ? const Center(child: Text('No runs saved yet.', style: TextStyle(color: AppColors.textSecondary)))
                          : ListView.builder(
                              itemCount: runProvider.runs.length,
                              itemBuilder: (context, index) {
                                final run = runProvider.runs[index];
                                return RunListItem(
                                   key: ValueKey(run.id),
                                   runObject: run,
                                   index: index,
                                   onDelete: () => runProvider.deleteRun(run.id),
                                );
                              },
                            ),
                ),
              ],
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