import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:georeminder/data/reminder_model.dart';
import 'package:georeminder/data/reminder_repository.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Reminder> box;
  late ReminderRepository repository;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ReminderAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<Reminder>(ReminderRepository.boxName);
    repository = ReminderRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('addReminder persiste e genera id e createdAt', () async {
    final reminder = await repository.addReminder(
      title: 'Compra latte',
      description: 'Supermercato',
      latitude: 43.8,
      longitude: 7.5,
      radius: 150,
    );

    expect(reminder.id, isNotEmpty);
    expect(reminder.isActive, isTrue);
    expect(box.length, 1);
  });

  test('round-trip su disco preserva tutti i campi', () async {
    final saved = await repository.addReminder(
      title: 'Farmacia',
      latitude: 44.1,
      longitude: 8.2,
    );

    // Chiude e riapre il box per forzare lettura da disco (adapter incluso)
    await box.close();
    box = await Hive.openBox<Reminder>(ReminderRepository.boxName);

    final loaded = box.get(saved.id)!;
    expect(loaded.title, 'Farmacia');
    expect(loaded.description, isNull);
    expect(loaded.latitude, 44.1);
    expect(loaded.longitude, 8.2);
    expect(loaded.radius, 200);
    expect(loaded.createdAt, saved.createdAt);
    expect(loaded.isActive, isTrue);
  });

  test('getAllReminders restituisce tutti i reminder salvati', () async {
    await repository.addReminder(title: 'A', latitude: 1, longitude: 1);
    await repository.addReminder(title: 'B', latitude: 2, longitude: 2);

    final all = repository.getAllReminders();
    expect(all.map((r) => r.title).toSet(), {'A', 'B'});
  });

  test('updateReminder sovrascrive il reminder con lo stesso id', () async {
    final original = await repository.addReminder(
      title: 'Originale',
      latitude: 1,
      longitude: 1,
    );

    await repository.updateReminder(
      original.copyWith(title: 'Modificato', isActive: false),
    );

    final updated = box.get(original.id)!;
    expect(box.length, 1);
    expect(updated.title, 'Modificato');
    expect(updated.isActive, isFalse);
    expect(updated.createdAt, original.createdAt);
  });

  test('deleteReminder rimuove il reminder', () async {
    final reminder = await repository.addReminder(
      title: 'Da eliminare',
      latitude: 1,
      longitude: 1,
    );

    await repository.deleteReminder(reminder.id);
    expect(box.isEmpty, isTrue);
  });
}
