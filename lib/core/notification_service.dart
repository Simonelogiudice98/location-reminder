import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reminder_model.dart';

/// Servizio per le notifiche locali.
///
/// Configura flutter_local_notifications e mostra una notifica quando, alla
/// riapertura dell'app, l'utente è entro il raggio di uno o più reminder
/// attivi (T7 — Notifiche MVP).
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'proximity';
  static const _channelName = 'Promemoria vicini';
  static const _channelDescription =
      'Avvisi quando sei vicino a un promemoria salvato.';

  /// ID fisso: una nuova notifica sostituisce la precedente invece di
  /// accumularsi nella barra a ogni apertura dell'app.
  static const _notificationId = 0;

  /// Inizializza il plugin e richiede il permesso notifiche.
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    // Android 13+ richiede il permesso runtime POST_NOTIFICATIONS.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Mostra una notifica per i reminder nel raggio.
  ///
  /// 0 match → nessuna notifica; 1 match → titolo del reminder; più match →
  /// un'unica notifica di riepilogo.
  Future<void> showNearby(List<Reminder> matched) async {
    if (matched.isEmpty) return;

    final String title;
    final String body;
    if (matched.length == 1) {
      final r = matched.single;
      title = 'Sei vicino a: ${r.title}';
      body = (r.description?.trim().isNotEmpty ?? false)
          ? r.description!.trim()
          : 'Raggio ${r.radius.round()} m';
    } else {
      title = 'Promemoria nelle vicinanze';
      body = 'Sei vicino a ${matched.length} promemoria';
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();

    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
    );
  }
}

/// Servizio notifiche: il valore concreto (già inizializzato) viene fornito
/// via override in `main()`.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(
    'notificationServiceProvider va fornito via overrideWithValue() nel '
    'ProviderScope di main.dart, con un NotificationService già inizializzato '
    '(init() è asincrono).',
  ),
);
