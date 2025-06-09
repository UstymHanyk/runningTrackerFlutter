import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/profile_cubit.dart';

class EditProfileForm extends StatefulWidget {
  final String initialName;

  const EditProfileForm({
    super.key,
    required this.initialName,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white30,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          TextFormField(
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
          ),
          const SizedBox(height: 20),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final isUpdating = state is ProfileUpdating;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: isUpdating ? null : () {
                      context.read<ProfileCubit>().cancelEditing();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isUpdating ? null : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().updateProfile(
                          _nameController.text.trim(),
                        );
                      }
                    },
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
} 