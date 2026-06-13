/// Dati raccolti dal form di creazione/modifica, non ancora persistiti.
///
/// DTO puro, volutamente senza dipendenze da Flutter/Hive/Riverpod: è il
/// valore di ritorno del bottom sheet e diventa l'input di
/// `ReminderRepository.addReminder` / `RemindersNotifier.applyDraft`.
class ReminderDraft {
  final String title;
  final String? description;
  final double latitude;
  final double longitude;

  /// Raggio di attivazione in metri.
  final double radius;

  const ReminderDraft({
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}
