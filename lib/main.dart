import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/navigation/route_generator.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/services/auth_provider.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/run_provider.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/microcontroller_service.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/cubits/qr_scanner_cubit.dart';
import 'package:my_project/cubits/main_screen_cubit.dart';
import 'package:my_project/cubits/heart_rate_cubit.dart';
import 'package:my_project/cubits/auth_cubit.dart';
import 'package:my_project/cubits/profile_cubit.dart';
import 'package:my_project/services/mqtt_service.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // Existing Provider pattern services
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
        ChangeNotifierProvider<MicrocontrollerService>(create: (_) => MicrocontrollerService()),
        ChangeNotifierProvider<MqttService>(create: (_) => MqttService()),
        
        // New Cubit providers
        BlocProvider<MicrocontrollerCubit>(
          create: (context) => MicrocontrollerCubit(
            Provider.of<MicrocontrollerService>(context, listen: false),
          ),
        ),
        BlocProvider<QRScannerCubit>(
          create: (_) => QRScannerCubit(),
        ),
        BlocProvider<MainScreenCubit>(
          create: (context) => MainScreenCubit(
            Provider.of<AuthProviderInterface>(context, listen: false),
            Provider.of<RunProviderInterface>(context, listen: false),
          ),
        ),
        BlocProvider<HeartRateCubit>(
          create: (context) => HeartRateCubit(
            Provider.of<MqttService>(context, listen: false),
            Provider.of<ConnectivityService>(context, listen: false),
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            Provider.of<AuthProviderInterface>(context, listen: false),
          ),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            Provider.of<AuthProviderInterface>(context, listen: false),
            Provider.of<RunProviderInterface>(context, listen: false),
          ),
        ),
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
