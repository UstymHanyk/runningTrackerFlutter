import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/widgets/main_screen/logout_dialog.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
          icon: const Icon(Icons.settings_input_antenna),
          tooltip: 'Device Configuration',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.microcontroller);
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
              LogoutDialog.show(context);
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 