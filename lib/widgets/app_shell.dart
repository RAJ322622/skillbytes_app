import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Which nav item is currently selected.
enum AppTab { home, courses, profile }

/// Shared scaffold shell used by Home, Courses, Profile.
/// Renders a bottom nav on phones and a sidebar on wider screens.
/// Navigation is delegated to the parent via [onTabSelected].
class AppShell extends StatelessWidget {
  final AppTab currentTab;
  final Widget body;
  final ValueChanged<AppTab> onTabSelected;

  const AppShell({
    super.key,
    required this.currentTab,
    required this.body,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            return Row(
              children: [
                if (wide)
                  AppSidebar(
                    currentTab: currentTab,
                    onSelect: onTabSelected,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: body),
                      if (!wide)
                        AppBottomNav(
                          currentTab: currentTab,
                          onSelect: onTabSelected,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SIDEBAR (wide screens)
// ---------------------------------------------------------------------------

class AppSidebar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onSelect;

  const AppSidebar({
    super.key,
    required this.currentTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SkillBytes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText : AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: border),
            const SizedBox(height: 12),
            _navItem(
              context,
              Icons.home_outlined,
              'Home',
              AppTab.home,
            ),
            _navItem(
              context,
              Icons.grid_view_outlined,
              'Courses',
              AppTab.courses,
            ),
            _navItem(
              context,
              Icons.person_outline,
              'Profile',
              AppTab.profile,
            ),
            const SizedBox(height: 24),
            _promoCard(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    AppTab tab,
  ) {
    final selected = currentTab == tab;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.secondaryTextColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.primaryColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: ListTile(
          leading: Icon(
            icon,
            color: selected ? AppTheme.primaryColor : inactiveColor,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.primaryColor : inactiveColor,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onTap: () => onSelect(tab),
        ),
      ),
    );
  }

  Widget _promoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryColor.withValues(alpha: 0.15)
            : AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            color: AppTheme.primaryColor,
            size: 56,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep Learning!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your skills, your future!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  isDark ? AppTheme.darkSecondaryText : AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM NAV (phones)
// ---------------------------------------------------------------------------

class AppBottomNav extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onSelect;

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(
                context,
                Icons.home_outlined,
                Icons.home,
                'Home',
                AppTab.home,
              ),
              _item(
                context,
                Icons.grid_view_outlined,
                Icons.grid_view,
                'Courses',
                AppTab.courses,
              ),
              _item(
                context,
                Icons.person_outline,
                Icons.person,
                'Profile',
                AppTab.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    AppTab tab,
  ) {
    final selected = currentTab == tab;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.secondaryTextColor;

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppTheme.primaryColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppTheme.primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}