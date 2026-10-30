
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED: Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: Cloud Firestore
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;

  // ADDED: Firebase Authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  InputDecoration _decoration(
    String label, {
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
      errorMaxLines: 2,
    );
  }

  // UPDATED: Creates a Firebase account and saves the learner profile.
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // EXISTING FIREBASE: Create the authentication account.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Account creation failed.');
      }

      // EXISTING FIREBASE: Save the learner's name in the Auth profile.
      await user.updateDisplayName(_nameController.text.trim());

      // ADDED: Save the learner's information in Cloud Firestore.
      // The Firebase UID is used as the document ID.
      await FirebaseFirestore.instance
          .collection('learners')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'learner',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      // EXISTING NAVIGATION: Return to the previous screen.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // EXISTING ERROR HANDLING: Display Firebase signup errors.
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-up is not enabled in Firebase.';
          break;
        default:
          message = e.message ??
              'Unable to create account. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      // ADDED: Handle Firestore and unexpected errors.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your profile. Please check your connection '
            'or Firestore permissions.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Join SkillBytes',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Learn skills in small chunks',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration(
                        'Full name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration(
                        'Email address',
                        icon: Icons.email_outlined,
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isSubmitting,
                      obscureText: _hidePassword,
                      decoration: _decoration(
                        'Password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must contain at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_isSubmitting,
                      obscureText: _hideConfirmPassword,
                      decoration: _decoration(
                        'Confirm password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _hideConfirmPassword =
                                        !_hideConfirmPassword;
                                  });
                                },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        // EXISTING: Button and loading behavior unchanged.
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Back to Login',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
