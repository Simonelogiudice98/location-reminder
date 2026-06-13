import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/reminder_model.dart';
import 'reminder_card.dart';
import 'reminder_form_sheet.dart';
import 'reminders_providers.dart';

/// Schermata lista promemoria (schermata 3 del design handoff).
class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key, required this.onGoToMap});

  /// Porta alla tab Mappa (bottone dello stato vuoto).
  final VoidCallback onGoToMap;

  static const _emptyCircleColor = Color(0xFFE0F2F1);
  static const _emptyIconColor = Color(0xFF4DB6AC);

  String _countLabel(int count) => switch (count) {
        0 => 'Nessun luogo salvato',
        1 => '1 luogo salvato',
        _ => '$count luoghi salvati',
      };

  Future<void> _editReminder(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final draft = await ReminderFormSheet.show(
      context,
      LatLng(reminder.latitude, reminder.longitude),
      initial: reminder,
    );
    if (draft != null) {
      await ref.read(remindersProvider.notifier).applyDraft(reminder.id, draft);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: _emptyCircleColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wrong_location_outlined,
                size: 60,
                color: _emptyIconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nessun promemoria ancora',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Torna sulla mappa e tieni premuto per aggiungerne uno!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGoToMap,
              icon: const Icon(Icons.map_outlined, size: 20),
              label: const Text('Vai alla mappa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: Color(0xFF9AA0A6),
          ),
        ),
      );

  List<Widget> _section(
    BuildContext context,
    WidgetRef ref,
    String label,
    List<Reminder> reminders,
  ) {
    if (reminders.isEmpty) return const [];
    return [
      _sectionHeader(label),
      const SizedBox(height: 8),
      for (final reminder in reminders) ...[
        ReminderCard(
          reminder: reminder,
          onToggle: () =>
              ref.read(remindersProvider.notifier).toggleActive(reminder.id),
          onEdit: () => _editReminder(context, ref, reminder),
          onDelete: () =>
              ref.read(remindersProvider.notifier).removeReminder(reminder.id),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Reminder> reminders,
  ) {
    final active = reminders.where((r) => r.isActive).toList();
    final inactive = reminders.where((r) => !r.isActive).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._section(context, ref, 'ATTIVI', active),
        ..._section(context, ref, 'INATTIVI', inactive),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, size: 16, color: Color(0xFFB0B6BB)),
              SizedBox(width: 8),
              Text(
                'Scorri una card per modificarla o eliminarla',
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B6BB)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I miei Promemoria',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              _countLabel(reminders.length),
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: reminders.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context, ref, reminders),
    );
  }
}
