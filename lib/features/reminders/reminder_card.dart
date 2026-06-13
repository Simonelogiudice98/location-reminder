import 'package:flutter/material.dart';

import '../../data/reminder_model.dart';

/// Card di un reminder nella lista (ReminderCard del design handoff).
///
/// Swipe a destra → modifica (sfondo teal), swipe a sinistra → elimina
/// (sfondo rosso, con dialog di conferma). La card non viene mai rimossa
/// dal [Dismissible] stesso: l'eliminazione passa da [onDelete], così la
/// lista resta guidata solo dallo stato Riverpod.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback onToggle;
  final Future<void> Function() onEdit;
  final VoidCallback onDelete;

  static const _deleteColor = Color(0xFFE5484D);
  static const _iconCircleColor = Color(0xFFE0F2F1);

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare il promemoria?'),
        content: Text('"${reminder.title}" verrà eliminato definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _deleteColor),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Widget _swipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(reminder.id),
      background: _swipeBackground(
        color: theme.colorScheme.primary,
        icon: Icons.edit_outlined,
        label: 'Modifica',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBackground(
        color: _deleteColor,
        icon: Icons.delete_outline,
        label: 'Elimina',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onEdit();
        } else if (await _confirmDelete(context) ?? false) {
          onDelete();
        }
        // Mai dismissare qui: è lo stato Riverpod a togliere la card.
        return false;
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _iconCircleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Raggio ${reminder.radius.round()} m',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: reminder.isActive,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
