import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/profile_cubit.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/widgets/profile/profile_header.dart';
import 'package:my_project/widgets/profile/edit_profile_form.dart';
import 'package:my_project/widgets/profile/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the cubit when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().initialize();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<ProfileCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileError) {
            if (state.message.contains('Not logged in')) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state is ProfileError ? state.message : 'Not logged in'),
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

          if (state is ProfileLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (state.isEditing)
                      EditProfileForm(initialName: state.name)
                    else ...[
                      ProfileHeader(name: state.name, email: state.email),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<ProfileCubit>().startEditing();
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    ],
                    const ProfileMenu(),
                  ],
                ),
              ),
            );
          }

          // Loading or updating states
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
} 