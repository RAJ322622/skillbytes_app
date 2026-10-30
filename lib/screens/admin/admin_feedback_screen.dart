
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'all';
  bool _checkingAdmin = true;
  bool _isAdmin = false;
  bool _isUpdating = false;
  String? _authorizationError;

  static const Map<String, String> _statusLabels = {
    'new': 'New',
    'reviewed': 'Reviewed',
    'resolved': 'Resolved',
  };

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Please sign in to continue.');
      }

      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();

      if (!mounted) return;

      setState(() {
        _isAdmin = adminDoc.exists;
        _checkingAdmin = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _authorizationError = error.toString();
        _checkingAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateFeedbackStatus(
    String feedbackId,
    String status,
  ) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback marked as ${_statusLabels[status]}.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update feedback: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';

    final date = value.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'reviewed':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'new':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Learner Feedback'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_checkingAdmin) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_authorizationError != null) {
      return _messageView(
        Icons.error_outline,
        'Unable to verify admin access',
        _authorizationError!,
      );
    }

    if (!_isAdmin) {
      return _messageView(
        Icons.lock_outline,
        'Access denied',
        'Only authorized administrators can view feedback.',
      );
    }

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('feedback')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _messageView(
                  Icons.error_outline,
                  'Unable to load feedback',
                  snapshot.error.toString(),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final documents = snapshot.data?.docs ?? [];

              final filtered = documents.where((doc) {
                final data = doc.data();

                final message =
                    (data['message'] ?? '').toString().toLowerCase();
                final email =
                    (data['email'] ?? '').toString().toLowerCase();
                final status =
                    (data['status'] ?? 'new').toString().toLowerCase();

                final matchesSearch =
                    message.contains(_searchQuery) ||
                    email.contains(_searchQuery);

                final matchesStatus = _selectedStatus == 'all' ||
                    status == _selectedStatus;

                return matchesSearch && matchesStatus;
              }).toList();

              filtered.sort((a, b) {
                final aDate = a.data()['createdAt'];
                final bDate = b.data()['createdAt'];

                final aMillis =
                    aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
                final bMillis =
                    bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;

                return bMillis.compareTo(aMillis);
              });

              if (filtered.isEmpty) {
                return _messageView(
                  Icons.feedback_outlined,
                  'No feedback found',
                  _searchQuery.isEmpty && _selectedStatus == 'all'
                      ? 'Learner feedback will appear here.'
                      : 'Try changing your search or status filter.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final doc = filtered[index];

                  return _buildFeedbackCard(
                    doc.id,
                    doc.data(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review suggestions and track their progress.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search message or email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filter by status',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All feedback')),
              DropdownMenuItem(value: 'new', child: Text('New')),
              DropdownMenuItem(value: 'reviewed', child: Text('Reviewed')),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(
    String feedbackId,
    Map<String, dynamic> data,
  ) {
    final email = (data['email'] ?? 'Unknown learner').toString();
    final message = (data['message'] ?? '').toString();
    final status = (data['status'] ?? 'new').toString().toLowerCase();
    final rating = (data['rating'] as num?)?.toInt() ?? 0;
    final createdAt = _formatDate(data['createdAt']);

    final statusColor = _statusColor(status);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFCE7F3),
                  child: Icon(
                    Icons.feedback_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabels[status] ?? status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (rating > 0) ...[
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 19,
                    color: Colors.orange,
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message.isEmpty ? 'No message provided.' : message,
              style: const TextStyle(
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Update status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusButton(feedbackId, 'new'),
                _statusButton(feedbackId, 'reviewed'),
                _statusButton(feedbackId, 'resolved'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String feedbackId, String status) {
    final color = _statusColor(status);

    return OutlinedButton(
      onPressed: _isUpdating
          ? null
          : () => _updateFeedbackStatus(feedbackId, status),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.65)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(_statusLabels[status] ?? status),
    );
  }

  Widget _messageView(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
