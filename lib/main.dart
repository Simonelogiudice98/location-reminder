import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notification_service.dart';
import 'data/reminder_model.dart';
import 'data/reminder_repository.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>(ReminderRepository.boxName);

  // Inizializza le notifiche prima di runApp così sono pronte per il
  // controllo di prossimità all'apertura (HomeShell).
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const GeoReminderApp(),
    ),
  );
}

class GeoReminderApp extends StatelessWidget {
  const GeoReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoReminder',
      theme: ThemeData(
        // Il seed da solo genera un tonal palette diverso dal design system:
        // forziamo il primary al teal #00897B della spec.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
        ).copyWith(primary: const Color(0xFF00897B)),
      ),
      home: const HomeShell(),
    );
  }
}
