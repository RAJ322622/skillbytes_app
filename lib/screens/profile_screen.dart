import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'feedback_screen.dart';
class ProfileScreen extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  const ProfileScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textColor;

    return AppShell(
      currentTab: AppTab.profile,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('learner@skillbytes.app'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _tile(context, Icons.school_outlined, 'My Courses'),
            _tile(context, Icons.bar_chart_outlined, 'Progress'),
            _tile(context, Icons.settings_outlined, 'Settings'),
            _tile(
                  context,
                  Icons.feedback_outlined,
                  'Feedback & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                ),
            _tile(context, Icons.logout, 'Logout', danger: true,
                onTap: () => Navigator.pushReplacementNamed(context, '/')),
          ],
        ),
      ),
      onTabSelected: (tab) => onTabChange(tab.index),

    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label, {
    bool danger = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;
    final color = danger ? Colors.red : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label coming soon')),
                );
              },
        ),
      ),
    );
  }
}