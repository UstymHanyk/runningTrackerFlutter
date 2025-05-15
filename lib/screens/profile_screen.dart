import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateForCurrentUser();
    });
  }

  void _updateForCurrentUser() {
    final authProvider = Provider.of<AuthProviderInterface>(context, listen: false);
    final runProvider = Provider.of<RunProviderInterface>(context, listen: false);
    
    runProvider.checkUserAndReload(authProvider.currentUser?.email);
    
    if (authProvider.currentUser != null) {
      _nameController.text = authProvider.currentUser!.name;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
              final authProvider = Provider.of<AuthProviderInterface>(context, listen: false);
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProviderInterface>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not logged in'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
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
                    _isEditing
                        ? TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Name should not contain numbers';
                              }
                              return null;
                            },
                          )
                        : Text(
                            authProvider.currentUser?.name ?? 'User Name', 
                            style: theme.textTheme.headlineMedium,
                          ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.currentUser?.email ?? 'user@example.com', 
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameController.text = authProvider.currentUser?.name ?? '';
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final success = await authProvider.updateUserProfile(
                                          _nameController.text.trim(),
                                        );
                                        
                                        if (context.mounted && success) {
                                          setState(() {
                                            _isEditing = false;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Profile updated successfully')),
                                          );
                                        }
                                      }
                                    },
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
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
                    const SizedBox(height: 40),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          authProvider.logout();
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
            ),
          );
        },
      ),
    );
  }
} 