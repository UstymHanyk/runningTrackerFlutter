import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/navigation/route_generator.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:my_project/services/auth_provider.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/run_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProviderInterface>(create: (_) => AuthProvider()),
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
      title: 'Flutter Running Tracker',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
