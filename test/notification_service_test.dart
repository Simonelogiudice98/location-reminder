import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georeminder/core/notification_service.dart';
import 'package:georeminder/data/reminder_model.dart';

/// Posizione fittizia per i test: contano solo lat/lng.
Position _position(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

Reminder _reminder({
  required String id,
  required double lat,
  required double lng,
  double radius = 200,
  bool isActive = true,
}) =>
    Reminder(
      id: id,
      title: id,
      latitude: lat,
      longitude: lng,
      radius: radius,
      createdAt: DateTime(2026, 1, 1),
      isActive: isActive,
    );

void main() {
  // Punto di riferimento dell'utente.
  final user = _position(45.0, 9.0);

  group('remindersInRange', () {
    test('include un reminder attivo sulla stessa posizione', () {
      final r = _reminder(id: 'qui', lat: 45.0, lng: 9.0);
      expect(remindersInRange(user, [r]), [r]);
    });

    test('include un reminder attivo entro il raggio (~111 m)', () {
      // +0.001° di latitudine ≈ 111 m, dentro il raggio di 200 m.
      final r = _reminder(id: 'vicino', lat: 45.001, lng: 9.0, radius: 200);
      expect(remindersInRange(user, [r]), [r]);
    });

    test('esclude un reminder oltre il raggio (~2.2 km)', () {
      // +0.02° di latitudine ≈ 2.2 km, fuori dal raggio di 200 m.
      final r = _reminder(id: 'lontano', lat: 45.02, lng: 9.0, radius: 200);
      expect(remindersInRange(user, [r]), isEmpty);
    });

    test('esclude un reminder disattivato anche se vicino', () {
      final r = _reminder(id: 'spento', lat: 45.0, lng: 9.0, isActive: false);
      expect(remindersInRange(user, [r]), isEmpty);
    });

    test('ritorna tutti i match quando più reminder sono nel raggio', () {
      final a = _reminder(id: 'a', lat: 45.0, lng: 9.0);
      final b = _reminder(id: 'b', lat: 45.001, lng: 9.0);
      final lontano = _reminder(id: 'c', lat: 45.02, lng: 9.0);
      final result = remindersInRange(user, [a, b, lontano]);
      expect(result, [a, b]);
    });

    test('lista vuota → nessun match', () {
      expect(remindersInRange(user, []), isEmpty);
    });
  });
}
