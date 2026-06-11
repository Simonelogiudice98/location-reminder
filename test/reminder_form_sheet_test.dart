import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:georeminder/features/reminders/reminder_form_sheet.dart';

void main() {
  const position = LatLng(45.4642, 9.19);

  /// Pompa un'app con un bottone che apre lo sheet e cattura il risultato.
  Future<ReminderDraft? Function()> pumpAndOpenSheet(
    WidgetTester tester,
  ) async {
    ReminderDraft? result;
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await ReminderFormSheet.show(context, position);
                closed = true;
              },
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    return () {
      expect(closed, isTrue, reason: 'lo sheet dovrebbe essersi chiuso');
      return result;
    };
  }

  Finder saveButton() =>
      find.widgetWithText(FilledButton, 'Salva promemoria');

  bool saveEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(saveButton()).enabled;

  testWidgets('Salva è disabilitato finché il titolo è vuoto', (tester) async {
    await pumpAndOpenSheet(tester);

    expect(saveEnabled(tester), isFalse);

    final titleField = find.widgetWithText(TextField, 'Titolo *');
    await tester.enterText(titleField, 'Comprare il latte');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);

    // Soli spazi = titolo ancora vuoto.
    await tester.enterText(titleField, '   ');
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('Salva ritorna il draft con i valori del form', (tester) async {
    final getResult = await pumpAndOpenSheet(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Titolo *'),
      '  Comprare il latte  ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Descrizione (opzionale)'),
      'Intero, due litri',
    );
    // Slider 50–1000 con 19 divisioni: trascina a fondo scala destro.
    final slider = find.byType(Slider);
    await tester.drag(slider, const Offset(400, 0));
    await tester.pump();

    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    final draft = getResult();
    expect(draft, isNotNull);
    expect(draft!.title, 'Comprare il latte');
    expect(draft.description, 'Intero, due litri');
    expect(draft.latitude, position.latitude);
    expect(draft.longitude, position.longitude);
    expect(draft.radius, 1000);
  });

  testWidgets('descrizione vuota diventa null nel draft', (tester) async {
    final getResult = await pumpAndOpenSheet(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Titolo *'),
      'Farmacia',
    );
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    final draft = getResult();
    expect(draft!.description, isNull);
    expect(draft.radius, 200, reason: 'raggio di default');
  });

  testWidgets('la X chiude lo sheet senza ritornare un draft', (tester) async {
    final getResult = await pumpAndOpenSheet(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(getResult(), isNull);
    expect(find.text('Nuovo promemoria'), findsNothing);
  });

  testWidgets('mostra le coordinate del pin formattate', (tester) async {
    await pumpAndOpenSheet(tester);

    expect(find.text('45.4642, 9.1900'), findsOneWidget);
    expect(find.text('POSIZIONE DAL PIN'), findsOneWidget);
  });
}
