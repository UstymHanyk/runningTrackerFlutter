import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/main_screen_cubit.dart';
import 'package:my_project/navigation/app_routes.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext alertContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(alertContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(alertContext).pop();
              _performLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  static void _performLogout(BuildContext context) {
    final cubit = context.read<MainScreenCubit>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Listen to cubit state changes
    final subscription = cubit.stream.listen((state) {
      if (state is MainScreenLogoutSuccess) {
        // Close loading dialog and navigate to login
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
      } else if (state is MainScreenError && context.mounted) {
        // Close loading dialog and show error
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to login after brief delay anyway
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
        });
      }
    });
    
    // Perform logout
    cubit.logout();
    
    // Cancel subscription after a timeout
    Future.delayed(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  }
} 