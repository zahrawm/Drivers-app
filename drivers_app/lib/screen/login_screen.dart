import 'package:drivers_app/provider/email_provider.dart';
import 'package:drivers_app/screen/home_screen.dart';
import 'package:drivers_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailProvider = Provider.of<EmailProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: emailProvider.emailController,
                onChanged: (_) => emailProvider.validateEmail(),
                decoration: InputDecoration(
                  labelText: 'Email or username',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  border: InputBorder.none,
                  errorText: emailProvider.errorText,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Button(
              text: 'Continue',
              color: Colors.green,
              onPressed: () {
                emailProvider.validateEmail();
                if (emailProvider.errorText == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {},
              child: const Text(
                'Email me a login link',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
