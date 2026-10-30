
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED: Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: Firestore
import '../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  // ADDED: Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ADDED: Require a signed-in learner before submitting feedback.
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit feedback.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // UPDATED: Save feedback permanently to Firestore.
      await _firestore.collection('feedback').add({
        'userId': user.uid,
        'email': user.email,
        'rating': _rating == 0 ? null : _rating,
        'message': _feedbackController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you! Your feedback has been submitted.',
          ),
        ),
      );

      _feedbackController.clear();

      setState(() {
        _rating = 0;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      // ADDED: Handle Firestore-specific errors.
      final message = e.code == 'permission-denied'
          ? 'Permission denied. Please check Firestore rules.'
          : 'Failed to save feedback. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to submit feedback. Please try again.',
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
        title: const Text('Feedback & Support'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Share Your Feedback',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Tell us how we can improve your SkillBytes '
                    'learning experience.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Rate your experience (optional)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;

                      return IconButton(
                        tooltip:
                            '$star star${star == 1 ? '' : 's'}',
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _rating = star;
                                });
                              },
                        icon: Icon(
                          star <= _rating
                              ? Icons.star
                              : Icons.star_border,
                          color: star <= _rating
                              ? AppTheme.warmOrange
                              : theme.disabledColor,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Your Feedback',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 5,
                    maxLength: 1000,
                    enabled: !_isSubmitting,
                    decoration: const InputDecoration(
                      hintText: 'Write your feedback here...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your feedback.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : _submitFeedback,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSubmitting
                            ? 'Submitting...'
                            : 'Submit Feedback',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
