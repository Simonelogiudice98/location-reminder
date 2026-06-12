import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/location_service.dart';
import '../../data/reminder_model.dart';
import '../reminders/reminder_form_sheet.dart';
import '../reminders/reminders_providers.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

/// Schermata principale: mappa centrata sull'utente con i pin dei reminder.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  /// Inquadratura iniziale (Italia) mostrata finché non arriva la posizione.
  static const _fallbackCamera = CameraPosition(
    target: LatLng(42.5, 12.5),
    zoom: 5,
  );
  static const _userZoom = 15.0;

  GoogleMapController? _mapController;
  LatLng? _userLatLng;
  bool _locationGranted = false;

  /// Pin del long press, visibile mentre il form di creazione è aperto.
  LatLng? _pendingPin;

  @override
  void initState() {
    super.initState();
    _centerOnUser();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _centerOnUser() async {
    final result =
        await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;

    switch (result) {
      case LocationSuccess(:final position):
        setState(() {
          _locationGranted = true;
          _userLatLng = LatLng(position.latitude, position.longitude);
        });
        // Se la mappa non è ancora pronta, ci pensa onMapCreated.
        await _animateToUser();
      case LocationFailure(:final reason):
        _showLocationFailure(reason);
    }
  }

  Future<void> _animateToUser() async {
    final target = _userLatLng;
    if (target == null) return;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, _userZoom),
    );
  }

  void _showLocationFailure(LocationFailureReason reason) {
    final message = switch (reason) {
      LocationFailureReason.serviceDisabled =>
        'Attiva i servizi di localizzazione per centrare la mappa.',
      LocationFailureReason.permissionDenied =>
        'Senza il permesso posizione la mappa non può centrarsi su di te.',
      LocationFailureReason.permissionDeniedForever =>
        'Permesso posizione negato: abilitalo dalle impostazioni.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: reason == LocationFailureReason.permissionDeniedForever
            ? SnackBarAction(
                label: 'Impostazioni',
                onPressed: () =>
                    ref.read(locationServiceProvider).openAppSettings(),
              )
            : null,
      ),
    );
  }

  Future<void> _onMapLongPress(LatLng position) async {
    setState(() => _pendingPin = position);
    // Tiene il pin visibile sopra il bottom sheet.
    unawaited(_mapController?.animateCamera(CameraUpdate.newLatLng(position)));

    final draft = await ReminderFormSheet.show(context, position);
    if (!mounted) return;

    if (draft != null) {
      await ref.read(remindersProvider.notifier).addFromDraft(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promemoria salvato')),
      );
    }
    setState(() => _pendingPin = null);
  }

  Set<Marker> _buildMarkers(List<Reminder> reminders) {
    final pendingPin = _pendingPin;
    return {
      for (final reminder in reminders)
        Marker(
          markerId: MarkerId(reminder.id),
          position: LatLng(reminder.latitude, reminder.longitude),
          infoWindow: InfoWindow(
            title: reminder.title,
            snippet: reminder.description,
          ),
        ),
      if (pendingPin != null)
        Marker(
          markerId: const MarkerId('pending-pin'),
          position: pendingPin,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('GeoReminder')),
      body: GoogleMap(
        initialCameraPosition: _fallbackCamera,
        onMapCreated: (controller) {
          _mapController = controller;
          _animateToUser();
        },
        markers: _buildMarkers(reminders),
        onLongPress: _onMapLongPress,
        myLocationEnabled: _locationGranted,
        myLocationButtonEnabled: _locationGranted,
      ),
    );
  }
}
