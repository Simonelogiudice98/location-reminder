import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:georeminder/data/reminder_model.dart';
import 'package:georeminder/data/reminder_repository.dart';
import 'package:georeminder/features/reminders/reminder_form_sheet.dart';
import 'package:georeminder/features/reminders/reminders_providers.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Reminder> box;
  late ReminderRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ReminderAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<Reminder>(ReminderRepository.boxName);
    repository = ReminderRepository(box);
    container = ProviderContainer(
      overrides: [
        reminderRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('build carica i reminder già presenti nel box', () async {
    await repository.addReminder(
      title: 'Compra latte',
      latitude: 43.8,
      longitude: 7.5,
    );

    final state = container.read(remindersProvider);
    expect(state, hasLength(1));
    expect(state.single.title, 'Compra latte');
  });

  test('addFromDraft persiste su Hive e aggiorna lo stato', () async {
    const draft = ReminderDraft(
      title: 'Farmacia',
      description: 'Ritira ricetta',
      latitude: 44.1,
      longitude: 8.2,
      radius: 350,
    );

    await container.read(remindersProvider.notifier).addFromDraft(draft);

    final state = container.read(remindersProvider);
    expect(state, hasLength(1));
    final saved = state.single;
    expect(saved.title, 'Farmacia');
    expect(saved.description, 'Ritira ricetta');
    expect(saved.radius, 350);
    expect(saved.isActive, isTrue);
    expect(box.get(saved.id), isNotNull);
  });

  test('toggleActive inverte isActive e persiste', () async {
    final saved = await repository.addReminder(
      title: 'Compra latte',
      latitude: 43.8,
      longitude: 7.5,
    );

    await container.read(remindersProvider.notifier).toggleActive(saved.id);

    expect(container.read(remindersProvider).single.isActive, isFalse);
    expect(box.get(saved.id)!.isActive, isFalse);

    await container.read(remindersProvider.notifier).toggleActive(saved.id);
    expect(box.get(saved.id)!.isActive, isTrue);
  });

  test('removeReminder elimina dal box e dallo stato', () async {
    final saved = await repository.addReminder(
      title: 'Compra latte',
      latitude: 43.8,
      longitude: 7.5,
    );

    await container.read(remindersProvider.notifier).removeReminder(saved.id);

    expect(container.read(remindersProvider), isEmpty);
    expect(box.get(saved.id), isNull);
  });

  test('applyDraft aggiorna i campi del form e preserva il resto', () async {
    final saved = await repository.addReminder(
      title: 'Farmacia',
      description: 'Ritira ricetta',
      latitude: 44.1,
      longitude: 8.2,
      radius: 150,
    );
    await container.read(remindersProvider.notifier).toggleActive(saved.id);

    // Descrizione assente nel draft: deve azzerarla (limite di copyWith).
    const draft = ReminderDraft(
      title: 'Farmacia comunale',
      latitude: 44.1,
      longitude: 8.2,
      radius: 400,
    );
    await container
        .read(remindersProvider.notifier)
        .applyDraft(saved.id, draft);

    final updated = box.get(saved.id)!;
    expect(updated.title, 'Farmacia comunale');
    expect(updated.description, isNull);
    expect(updated.radius, 400);
    expect(updated.isActive, isFalse, reason: 'lo stato attivo non si tocca');
    expect(updated.createdAt, saved.createdAt);
    expect(updated.latitude, saved.latitude);
    expect(container.read(remindersProvider).single.title, 'Farmacia comunale');
  });
}
