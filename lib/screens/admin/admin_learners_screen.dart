
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminLearnersScreen extends StatefulWidget {
  const AdminLearnersScreen({super.key});

  @override
  State<AdminLearnersScreen> createState() =>
      _AdminLearnersScreenState();
}

class _AdminLearnersScreenState extends State<AdminLearnersScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  bool _checkingAccess = true;
  bool _isAuthorized = false;
  String? _accessError;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final authorized =
          await _adminService.isCurrentUserAdmin();

      if (!mounted) return;

      setState(() {
        _isAuthorized = authorized;
        _checkingAccess = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _accessError = error.toString();
        _checkingAccess = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Not available';
    }

    final date = value.toDate().toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _filterLearners(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data();

      final name =
          (data['name'] ?? '').toString().toLowerCase();

      final email =
          (data['email'] ?? '').toString().toLowerCase();

      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Learners'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _checkingAccess
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _accessError != null
              ? _messageView(
                  Icons.error_outline,
                  'Unable to verify admin access',
                  _accessError!,
                )
              : !_isAuthorized
                  ? _messageView(
                      Icons.lock_outline,
                      'Access denied',
                      'Only authorized SkillBytes admins '
                          'can view registered learners.',
                    )
                  : _buildLearnersContent(),
    );
  }

  Widget _buildLearnersContent() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('learners')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _messageView(
            Icons.error_outline,
            'Unable to load learners',
            snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final allLearners = snapshot.data!.docs;

        allLearners.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];

          if (aDate is Timestamp && bDate is Timestamp) {
            return bDate.compareTo(aDate);
          }

          if (aDate is Timestamp) return -1;
          if (bDate is Timestamp) return 1;

          return 0;
        });

        final filteredLearners =
            _filterLearners(allLearners);

        return Column(
          children: [
            _buildHeader(
              totalLearners: allLearners.length,
            ),
            _buildSearchField(),
            Expanded(
              child: filteredLearners.isEmpty
                  ? _messageView(
                      Icons.people_outline,
                      _searchQuery.isEmpty
                          ? 'No learners registered yet'
                          : 'No matching learners',
                      _searchQuery.isEmpty
                          ? 'New learner accounts will '
                              'appear here after signup.'
                          : 'Try searching with another '
                              'name or email.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        24,
                      ),
                      itemCount: filteredLearners.length,
                      itemBuilder: (context, index) {
                        final doc = filteredLearners[index];

                        return _buildLearnerCard(
                          doc.id,
                          doc.data(),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader({
    required int totalLearners,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registered Learners',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalLearners',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name or email',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearnerCard(
    String uid,
    Map<String, dynamic> data,
  ) {
    final name = (data['name'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();

    final displayName =
        name.isEmpty ? 'Unnamed Learner' : name;

    final initial = displayName[0].toUpperCase();

    final joinedDate = _formatDate(data['createdAt']);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  AppTheme.primaryColor.withValues(
                alpha: 0.12,
              ),
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email.isEmpty
                        ? 'Email unavailable'
                        : email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Joined: $joinedDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View learner details',
              icon: Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                _showLearnerDetails(
                  uid,
                  displayName,
                  email,
                  joinedDate,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLearnerDetails(
    String uid,
    String name,
    String email,
    String joinedDate,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Learner Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow('Name', name),
              const SizedBox(height: 12),
              _detailRow(
                'Email',
                email.isEmpty ? 'Unavailable' : email,
              ),
              const SizedBox(height: 12),
              _detailRow('Joined', joinedDate),
              const SizedBox(height: 12),
              _detailRow('User ID', uid),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _messageView(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
