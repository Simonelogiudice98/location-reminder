import 'package:flutter/material.dart';

import '../map/map_screen.dart';
import '../reminders/reminders_list_screen.dart';

/// Contenitore principale: bottom navigation Mappa | Promemoria.
///
/// Le due schermate vivono in un [IndexedStack] così la mappa mantiene
/// camera e stato quando si cambia tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const MapScreen(),
          RemindersListScreen(onGoToMap: () => setState(() => _index = 0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Promemoria',
          ),
        ],
      ),
    );
  }
}
