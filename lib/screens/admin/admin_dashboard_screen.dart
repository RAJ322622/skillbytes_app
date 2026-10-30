
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  late Future<bool> _authorizationFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _authorizationFuture = _adminService.isCurrentUserAdmin();
    _statsFuture = _adminService.getDashboardStats();
  }

  Future<void> _refreshDashboard() async {
    setState(_loadDashboard);

    try {
      await _authorizationFuture;
      await _statsFuture;
    } catch (_) {
      // FutureBuilder displays the error in the dashboard UI.
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to sign out: $error'),
        ),
      );
    }
  }

  void _openAdminPage(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('SkillBytes Admin'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _authorizationFuture,
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (authSnapshot.hasError || authSnapshot.data != true) {
            return _buildAccessDenied(theme);
          }

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your SkillBytes learning platform.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Live statistics loaded from Firestore.
                FutureBuilder<Map<String, int>>(
                  future: _statsFuture,
                  builder: (context, statsSnapshot) {
                    if (statsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (statsSnapshot.hasError) {
                      return _buildStatsError(
                        statsSnapshot.error.toString(),
                      );
                    }

                    final stats = statsSnapshot.data ??
                        <String, int>{};

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth >= 700 ? 3 : 1;

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              columns == 3 ? 1.5 : 2.7,
                          children: [
                            _StatCard(
                              title: 'Courses',
                              value: stats['courses'] ?? 0,
                              icon: Icons.menu_book_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            _StatCard(
                              title: 'Learners',
                              value: stats['learners'] ?? 0,
                              icon: Icons.people_outline,
                              color: AppTheme.accentColor,
                            ),
                            _StatCard(
                              title: 'Feedback',
                              value: stats['feedback'] ?? 0,
                              icon: Icons.feedback_outlined,
                              color: AppTheme.warmOrange,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                Text(
                  'Management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _AdminMenuTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Course Management',
                  subtitle: 'Create, edit and manage courses',
                  onTap: () => _openAdminPage('/admin/courses'),
                ),
                _AdminMenuTile(
                  icon: Icons.people_outline,
                  title: 'Learner Management',
                  subtitle: 'View registered learner profiles',
                  onTap: () => _openAdminPage('/admin/learners'),
                ),
                _AdminMenuTile(
                  icon: Icons.feedback_outlined,
                  title: 'Feedback Management',
                  subtitle: 'Review learner feedback and ratings',
                  onTap: () => _openAdminPage('/admin/feedback'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccessDenied(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 58,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Admin access required',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This account has not been authorized to access '
              'the SkillBytes Admin dashboard.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsError(String error) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 38,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load dashboard statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check your internet connection, Firestore setup, '
              'and security rules.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
