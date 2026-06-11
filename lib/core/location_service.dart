import 'package:geolocator/geolocator.dart';

/// Esito di una richiesta di posizione.
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.position);

  final Position position;
}

class LocationFailure extends LocationResult {
  const LocationFailure(this.reason);

  final LocationFailureReason reason;
}

enum LocationFailureReason {
  /// Servizi di localizzazione disattivati a livello di sistema.
  serviceDisabled,

  /// Permesso negato: si può richiedere di nuovo in seguito.
  permissionDenied,

  /// Permesso negato in modo permanente: serve passare dalle impostazioni.
  permissionDeniedForever,
}

/// Servizio per l'accesso alla posizione del dispositivo.
///
/// Gestisce il permesso "Location When In Use" (MVP). Il permesso "Always"
/// arriverà solo in Fase 2 con il geofencing in background.
class LocationService {
  /// Verifica servizi e permesso, poi restituisce la posizione attuale.
  ///
  /// Richiede il permesso al sistema se non è ancora stato deciso.
  Future<LocationResult> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationFailure(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationFailure(LocationFailureReason.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationFailure(
        LocationFailureReason.permissionDeniedForever,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LocationSuccess(position);
  }

  /// Apre le impostazioni dell'app, per il caso [permissionDeniedForever].
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
