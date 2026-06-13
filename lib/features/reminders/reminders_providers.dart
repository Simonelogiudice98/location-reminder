import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/reminder_model.dart';
import '../../data/reminder_repository.dart';
import 'reminder_form_sheet.dart';

/// Repository dei reminder, costruito sul box Hive aperto in `main()`.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(Hive.box<Reminder>(ReminderRepository.boxName));
});

/// Stato dei reminder persistiti: la UI lo osserva, il notifier scrive
/// sul repository e riallinea lo stato dal box (unica fonte di verità).
class RemindersNotifier extends Notifier<List<Reminder>> {
  ReminderRepository get _repository => ref.read(reminderRepositoryProvider);

  @override
  List<Reminder> build() => _repository.getAllReminders();

  /// Persiste il draft compilato nel form di creazione.
  Future<void> addFromDraft(ReminderDraft draft) async {
    await _repository.addReminder(
      title: draft.title,
      description: draft.description,
      latitude: draft.latitude,
      longitude: draft.longitude,
      radius: draft.radius,
    );
    state = _repository.getAllReminders();
  }

  /// Applica al reminder esistente le modifiche fatte nel form.
  Future<void> applyDraft(String id, ReminderDraft draft) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final current = state[index];
    // Non copyWith: deve poter azzerare la descrizione.
    await _repository.updateReminder(Reminder(
      id: current.id,
      title: draft.title,
      description: draft.description,
      latitude: current.latitude,
      longitude: current.longitude,
      radius: draft.radius,
      createdAt: current.createdAt,
      isActive: current.isActive,
    ));
    state = _repository.getAllReminders();
  }

  Future<void> toggleActive(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final current = state[index];
    await _repository.updateReminder(
      current.copyWith(isActive: !current.isActive),
    );
    state = _repository.getAllReminders();
  }

  Future<void> removeReminder(String id) async {
    await _repository.deleteReminder(id);
    state = _repository.getAllReminders();
  }
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, List<Reminder>>(RemindersNotifier.new);
