import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
               Navigator.pushNamedAndRemoveUntil(
                 context,
                 AppRoutes.login,
                 (Route<dynamic> route) => false,
               );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white30,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'User Name', 
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
             Text(
              'user@example.com', 
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.directions_run),
              title: const Text('My Runs'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.main);
              },
            ),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Settings not implemented yet')),
                 );
              },
            ),
            const Divider(color: Colors.white24),
            const Spacer(),
             Center(
               child: TextButton(
                 onPressed: () {
                   Navigator.pushNamedAndRemoveUntil(
                     context,
                     AppRoutes.login,
                     (Route<dynamic> route) => false,
                   );
                 },
                 child: Text(
                   'Logout',
                   style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
                 ),
               ),
             ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 