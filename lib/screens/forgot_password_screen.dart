
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED: Firebase Authentication
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  // UPDATED: Send an actual Firebase password-reset email.
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
      // ADDED: Send password-reset email through Firebase.
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset link sent. Please check your email.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // ADDED: Handle Firebase password-reset errors.
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password authentication is not enabled in Firebase.';
          break;
        default:
          message = e.message ??
              'Unable to send reset email. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
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
        title: const Text('Forgot Password'),
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
                    const SizedBox(height: 24),

                    Text(
                      'Reset your password',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Enter the email address associated with '
                      'your account to request a password reset.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Login'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
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
