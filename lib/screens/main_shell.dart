import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'program_listing_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _setIndex(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        HomeScreen(onTabChange: _setIndex),
        ProgramListingScreen(onTabChange: _setIndex),
        ProfileScreen(onTabChange: _setIndex),
      ],
    );
  }
}