import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
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
  
  void _updateRunsForCurrentUser() {
    final authProvider = Provider.of<AuthProviderInterface>(context, listen: false);
    final runProvider = Provider.of<RunProviderInterface>(context, listen: false);
    
    // Check if user has changed and reload runs if needed
    runProvider.checkUserAndReload(authProvider.currentUser?.email);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Consumer<RunProviderInterface>(
        builder: (context, runProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                                   runData: {
                                     'name': run.name,
                                     'distance': run.distance,
                                   },
                                   index: index,
                                   onDelete: () => runProvider.deleteRun(run.id),
                                   runId: run.id,
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