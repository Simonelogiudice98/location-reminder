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
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, List<Reminder>>(RemindersNotifier.new);
