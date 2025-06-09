import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/widgets/auth/registration_form.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets edgeInsets = MediaQuery.of(context).viewPadding;
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
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
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // Registration Form
              const RegistrationForm(),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}