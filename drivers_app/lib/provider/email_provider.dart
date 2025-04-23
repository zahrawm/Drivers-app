import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  String? _errorText;
  String? get errorText => _errorText;
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Status tracking
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // User tracking
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
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
  
  // Sign in with email and password
  Future<bool> signInWithEmail(String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final email = emailController.text.trim();
      
      // Validate email first
      validateEmail();
      if (_errorText != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Sign in user with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login timestamp in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorText = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorText = 'Wrong password provided.';
      } else {
        _errorText = 'Authentication error: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorText = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Save email to Firestore
  Future<bool> saveEmailToFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final email = emailController.text.trim();
      
      // Validate email first
      validateEmail();
      if (_errorText != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Option 1: Save to Firestore without authentication
      await _firestore.collection('emails').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorText = 'Failed to save: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> createUserWithEmail(String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final email = emailController.text.trim();
      
      validateEmail();
      if (_errorText != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorText = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorText = 'The account already exists for that email.';
      } else {
        _errorText = 'Authentication error: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorText = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> sendPasswordResetEmail() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final email = emailController.text.trim();
    
      validateEmail();
      if (_errorText != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorText = 'Failed to send email: ${e.message}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorText = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      _errorText = 'Failed to sign out: ${e.toString()}';
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}