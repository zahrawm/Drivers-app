import 'package:flutter/material.dart';

class EmailProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  String? _errorText;

  String? get errorText => _errorText;

  void validateEmail() {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || emailRegex.hasMatch(email)) {
      _errorText = null;
    } else {
      _errorText = 'Email cannot be verified';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
