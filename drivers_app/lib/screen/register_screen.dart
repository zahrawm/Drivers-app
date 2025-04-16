import 'package:drivers_app/screen/login_screen.dart';
import 'package:drivers_app/screen/sign_up.dart';
import 'package:drivers_app/widgets/button.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bolt',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  TextSpan(text: ' '),

                  TextSpan(
                    text: 'Driver',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Drive with Bolt.\nEarn extra money driving.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const Spacer(flex: 3),
            Button(
              text: 'Log in',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),

            const SizedBox(height: 12),
            Button(
              text: 'Sign up',
              color: const Color.fromARGB(255, 246, 242, 242),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
