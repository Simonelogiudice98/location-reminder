import 'package:geolocator/geolocator.dart';

import '../data/reminder_model.dart';

/// Reminder attivi la cui distanza dalla [position] è entro il loro raggio.
///
/// Funzione pura (nessun canale di piattaforma): [Geolocator.distanceBetween]
/// è solo matematica, quindi è testabile senza un device.
List<Reminder> remindersInRange(Position position, List<Reminder> reminders) {
  return reminders.where((r) {
    if (!r.isActive) return false;
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      r.latitude,
      r.longitude,
    );
    return distance <= r.radius;
  }).toList();
}

/// Servizio di geofencing in background.
///
/// Riservato alla Fase 2: monitoraggio enter/exit dei geofence con app
/// chiusa, max 20 geofence attivi, aggiornamento dinamico.
class GeofenceService {}
