import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/navigation/route_generator.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:my_project/services/auth_provider.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/run_provider.dart';
import 'package:my_project/services/connectivity_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
        ChangeNotifierProxyProvider<ConnectivityService, AuthProviderInterface>(
          create: (context) => AuthProvider(
            connectivityService: Provider.of<ConnectivityService>(context, listen: false),
          ),
          update: (context, connectivity, previous) {
            final authProvider = previous as AuthProvider?;
            authProvider?.updateConnectivityStatus(connectivity.isConnected);
            return authProvider ?? AuthProvider(connectivityService: connectivity);
          },
        ),
        ChangeNotifierProvider<RunProviderInterface>(create: (_) => RunProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Heart Rate Monitor',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
