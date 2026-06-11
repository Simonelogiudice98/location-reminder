import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/reminder_model.dart';
import 'data/reminder_repository.dart';
import 'features/map/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>(ReminderRepository.boxName);
  runApp(const ProviderScope(child: GeoReminderApp()));
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
      home: const MapScreen(),
    );
  }
}
