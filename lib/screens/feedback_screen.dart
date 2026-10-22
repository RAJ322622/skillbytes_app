
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your feedback has been submitted.'),
      ),
    );

    _feedbackController.clear();

    setState(() {
      _rating = 0;
    });
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
                  Image.asset(
                  'assets/images/logo.png',
                  width: 84,
                  height: 84,
                  fit: BoxFit.contain,
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
                        tooltip: '$star star${star == 1 ? '' : 's'}',
                        onPressed: () {
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
                      onPressed: _submitFeedback,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Feedback'),
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
