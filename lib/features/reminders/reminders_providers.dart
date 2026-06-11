import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/reminder_model.dart';
import '../../data/reminder_repository.dart';

/// Repository dei reminder, costruito sul box Hive aperto in `main()`.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(Hive.box<Reminder>(ReminderRepository.boxName));
});
