import 'package:flutter/material.dart';

class ValidationProvider extends ChangeNotifier {
  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  final RegExp _ghanaPhoneRegExp = RegExp(
    r'^(0|\+233|233)?[23][0-9]{8}$',
  );

  String _email = '';
  String _phone = '';
  String _emailError = '';
  String _phoneError = '';
  bool _isFormValid = false;

  String get email => _email;
  String get phone => _phone;
  String get emailError => _emailError;
  String get phoneError => _phoneError;
  bool get isEmailValid => _emailError.isEmpty && _email.isNotEmpty;
  bool get isPhoneValid => _phoneError.isEmpty && _phone.isNotEmpty;
  bool get isFormValid => _isFormValid;

  void updateEmail(String value) {
    _email = value.trim();
    if (_email.isEmpty) {
      _emailError = 'Email is required';
    } else if (!_emailRegExp.hasMatch(_email)) {
      _emailError = 'Please enter a valid email address';
    } else {
      _emailError = '';
    }
    _validateForm();
    notifyListeners();
  }


  void updatePhone(String value) {
    _phone = value.trim();
    if (_phone.isEmpty) {
      _phoneError = 'Phone number is required';
    } else if (!_ghanaPhoneRegExp.hasMatch(_phone)) {
      _phoneError = 'Please enter a valid Ghana phone number';
    } else {
      _phoneError = '';
    }
    _validateForm();
    notifyListeners();
  }


  void _validateForm() {
    _isFormValid = isEmailValid && isPhoneValid && _termsAccepted;
  }

  bool _termsAccepted = false;
  bool get termsAccepted => _termsAccepted;

  void updateTermsAccepted(bool value) {
    _termsAccepted = value;
    _validateForm();
    notifyListeners();
  }

  void resetValidation() {
    _email = '';
    _phone = '';
    _emailError = '';
    _phoneError = '';
    _termsAccepted = false;
    _isFormValid = false;
    notifyListeners();
  }
}