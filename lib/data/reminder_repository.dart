import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'reminder_model.dart';

/// Repository CRUD dei reminder su storage locale Hive.
///
/// Il box viene iniettato dal costruttore così nei test si può usare un box
/// su directory temporanea senza dipendere da Flutter.
class ReminderRepository {
  static const boxName = 'reminders';

  final Box<Reminder> _box;
  static const _uuid = Uuid();

  ReminderRepository(this._box);

  /// Crea e persiste un nuovo reminder, generando id e timestamp.
  Future<Reminder> addReminder({
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    double radius = 200,
  }) async {
    // Hive serializza i DateTime al millisecondo: tronchiamo subito i
    // microsecondi così l'oggetto in memoria coincide con quello su disco.
    final now = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
    );
    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      createdAt: now,
    );
    await _box.put(reminder.id, reminder);
    return reminder;
  }

  List<Reminder> getAllReminders() => _box.values.toList();

  Future<void> updateReminder(Reminder reminder) =>
      _box.put(reminder.id, reminder);

  Future<void> deleteReminder(String id) => _box.delete(id);
}
