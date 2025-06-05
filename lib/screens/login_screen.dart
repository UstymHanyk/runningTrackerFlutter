import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:my_project/cubits/auth_cubit.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/widgets/auth/login_form.dart';
import 'package:my_project/widgets/auth/connectivity_banner.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check auto-login when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAutoLogin();
    });

    final EdgeInsets edgeInsets = MediaQuery.of(context).viewPadding;
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.main);
          }
        },
        child: Consumer<ConnectivityService>(
          builder: (context, connectivityService, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20.0,
                  horizontalPadding,
                  edgeInsets.bottom + 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'IoT Heart Rate Monitor',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    
                    // Connection status banner
                    ConnectivityBanner(isConnected: connectivityService.isConnected),
                    
                    // Login Form
                    const LoginForm(),
                    
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    // Quick access to heart rate dashboard for demo
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.heartRateDashboard);
                      },
                      icon: const Icon(Icons.monitor_heart, color: Colors.red),
                      label: const Text(
                        'Quick Access - Heart Rate Monitor',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 