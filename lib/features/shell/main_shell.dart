import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../tasks/presentation/task_list_screen.dart';

/// Негізгі қабық: төменгі NavigationBar (5 бөлім). IndexedStack әр бөлімнің күйін сақтайды.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onOpenTasks: () => _go(1)),
      const TaskListScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppStrings.navHome),
          NavigationDestination(
              icon: Icon(Icons.checklist),
              selectedIcon: Icon(Icons.checklist_rtl),
              label: AppStrings.navTasks),
          NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: AppStrings.navSearch),
          NavigationDestination(
              icon: Icon(Icons.star_border),
              selectedIcon: Icon(Icons.star),
              label: AppStrings.navFavorites),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.navProfile),
        ],
      ),
    );
  }
}
