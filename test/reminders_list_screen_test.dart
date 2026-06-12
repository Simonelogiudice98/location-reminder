import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:georeminder/data/reminder_model.dart';
import 'package:georeminder/data/reminder_repository.dart';
import 'package:georeminder/features/reminders/reminders_list_screen.dart';
import 'package:georeminder/features/reminders/reminders_providers.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Reminder> box;
  late ReminderRepository repository;

  setUpAll(() {
    Hive.registerAdapter(ReminderAdapter());
  });

  setUp(() async {
    // Box in memoria (`bytes:`): niente I/O su file, che nella zona
    // FakeAsync dei testWidgets non completerebbe mai (test appesi).
    box = await Hive.openBox<Reminder>(
      ReminderRepository.boxName,
      bytes: Uint8List(0),
    );
    repository = ReminderRepository(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  Future<void> pumpListScreen(
    WidgetTester tester, {
    VoidCallback? onGoToMap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: RemindersListScreen(onGoToMap: onGoToMap ?? () {}),
        ),
      ),
    );
  }

  testWidgets('box vuoto: mostra lo stato vuoto e il bottone funziona',
      (tester) async {
    var wentToMap = false;
    await pumpListScreen(tester, onGoToMap: () => wentToMap = true);

    expect(find.text('Nessun promemoria ancora'), findsOneWidget);
    expect(find.text('Nessun luogo salvato'), findsOneWidget);

    await tester.tap(find.text('Vai alla mappa'));
    expect(wentToMap, isTrue);
  });

  testWidgets('mostra titolo, raggio e conteggio dei reminder',
      (tester) async {
    await repository.addReminder(
      title: 'Comprare il latte',
      latitude: 43.8,
      longitude: 7.5,
      radius: 200,
    );
    await pumpListScreen(tester);

    expect(find.text('Comprare il latte'), findsOneWidget);
    expect(find.text('Raggio 200 m'), findsOneWidget);
    expect(find.text('1 luogo salvato'), findsOneWidget);
  });

  testWidgets('tap sul toggle disattiva il reminder', (tester) async {
    final saved = await repository.addReminder(
      title: 'Comprare il latte',
      latitude: 43.8,
      longitude: 7.5,
    );
    await pumpListScreen(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(box.get(saved.id)!.isActive, isFalse);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('swipe a sinistra chiede conferma; Annulla non elimina',
      (tester) async {
    final saved = await repository.addReminder(
      title: 'Comprare il latte',
      latitude: 43.8,
      longitude: 7.5,
    );
    await pumpListScreen(tester);

    await tester.drag(find.text('Comprare il latte'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Eliminare il promemoria?'), findsOneWidget);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(box.get(saved.id), isNotNull);
    expect(find.text('Comprare il latte'), findsOneWidget);
  });

  testWidgets('swipe a sinistra + conferma elimina il reminder',
      (tester) async {
    final saved = await repository.addReminder(
      title: 'Comprare il latte',
      latitude: 43.8,
      longitude: 7.5,
    );
    await pumpListScreen(tester);

    await tester.drag(find.text('Comprare il latte'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(box.get(saved.id), isNull);
    expect(find.text('Nessun promemoria ancora'), findsOneWidget);
  });

  testWidgets('swipe a destra apre lo sheet di modifica precompilato',
      (tester) async {
    await repository.addReminder(
      title: 'Comprare il latte',
      description: 'Intero',
      latitude: 43.8,
      longitude: 7.5,
    );
    await pumpListScreen(tester);

    await tester.drag(find.text('Comprare il latte'), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Modifica promemoria'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Comprare il latte'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Intero'), findsOneWidget);
  });
}
