import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white30,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          email,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
} 