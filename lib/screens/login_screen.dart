import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/auth_provider.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure context is still valid if we need it after an async gap
      if (mounted) {
        _checkAutoLogin();
      }
    });
  }

  Future<void> _checkAutoLogin() async {
    // Capture the context before the async gap if it's needed afterwards.
    // However, in this specific logic, we only need the mounted check before navigation.
    final authProvider = context.read<AuthProviderInterface>() as AuthProvider;

    if (authProvider.isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
      return;
    }

    try {
      final success = await authProvider.loginWithStoredCredentials();
      if (mounted && success && authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer2<AuthProviderInterface, ConnectivityService>(
        builder: (context, authProvider, connectivityService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20.0,
                horizontalPadding,
                edgeInsets.bottom + 20.0,
              ),
              child: Form(
                key: _formKey,
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
                    if (!connectivityService.isConnected)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No internet connection detected',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIconData: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIconData: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            authProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: authProvider.isLoading 
                          ? null 
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                debugPrint('Attempting login with email: ${_emailController.text.trim()}');
                                
                                final success = await authProvider.login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                                
                                debugPrint('Login result: $success');
                                
                                if (context.mounted && success) {
                                  debugPrint('Login successful, navigating to main screen');
                                  Navigator.pushReplacementNamed(context, AppRoutes.main);
                                } else {
                                  debugPrint('Login failed: ${authProvider.error}');
                                }
                              }
                            },
                      child: authProvider.isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
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
            ),
          );
        },
      ),
    );
  }
} 