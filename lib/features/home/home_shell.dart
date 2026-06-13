import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location_service.dart';
import '../../core/notification_service.dart';
import '../map/map_screen.dart';
import '../reminders/reminders_list_screen.dart';
import '../reminders/reminders_providers.dart';

/// Contenitore principale: bottom navigation Mappa | Promemoria.
///
/// Le due schermate vivono in un [IndexedStack] così la mappa mantiene
/// camera e stato quando si cambia tab.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Notifiche MVP: una sola volta all'apertura controlla se sei vicino a
    // un reminder attivo (T7). Post-frame perché serve il primo build fatto.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkProximity());
  }

  Future<void> _checkProximity() async {
    final result = await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;
    if (result is! LocationSuccess) return; // failure: la mappa già lo segnala
    final matched = remindersInRange(
      result.position,
      ref.read(remindersProvider),
    );
    if (!mounted) return;
    await ref.read(notificationServiceProvider).showNearby(matched);
    if (!mounted) return; // guardia anche dopo l'ultimo await (difensiva)
  }

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
