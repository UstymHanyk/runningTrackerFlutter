import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/profile_cubit.dart';
import 'package:my_project/navigation/app_routes.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: [
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
        const SizedBox(height: 40),
        Center(
          child: TextButton(
            onPressed: () {
              context.read<ProfileCubit>().logout();
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
    );
  }
} 