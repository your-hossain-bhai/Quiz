import 'package:flutter/material.dart';

import 'package:quiz_app/pages/profile_page.dart';
import 'package:quiz_app/pages/scoreboard_page.dart';
import 'category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [CategoryPage(), ScoreboardPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: colorScheme.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.leaderboard_outlined),
                selectedIcon: Icon(
                  Icons.leaderboard,
                  color: colorScheme.primary,
                ),
                label: 'Leaderboard',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: colorScheme.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
