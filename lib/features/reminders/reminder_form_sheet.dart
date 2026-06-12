import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/reminder_model.dart';

/// Dati raccolti dal form di creazione, non ancora persistiti.
///
/// Volutamente senza dipendenze da Hive/Riverpod: è il valore di ritorno
/// del bottom sheet e diventerà l'input di `ReminderRepository.addReminder`.
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

/// Bottom sheet di creazione/modifica reminder (schermata 2 del design
/// handoff).
///
/// Si apre con [ReminderFormSheet.show]; ritorna il [ReminderDraft]
/// compilato, o `null` se l'utente annulla (X, scrim, back).
/// Con [initial] valorizzato lavora in modalità modifica: campi
/// precompilati e posizione (sempre read-only) presa dal reminder.
class ReminderFormSheet extends StatefulWidget {
  const ReminderFormSheet({super.key, required this.position, this.initial});

  /// Punto del long press: posizione read-only del reminder.
  final LatLng position;

  /// Reminder da modificare; `null` in creazione.
  final Reminder? initial;

  static Future<ReminderDraft?> show(
    BuildContext context,
    LatLng position, {
    Reminder? initial,
  }) {
    return showModalBottomSheet<ReminderDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReminderFormSheet(position: position, initial: initial),
    );
  }

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  static const _minRadius = 50.0;
  static const _maxRadius = 1000.0;
  static const _defaultRadius = 200.0;

  // Colori del design handoff non coperti dal tema.
  static const _coordsBoxColor = Color(0xFFE0F2F1);
  static const _closeButtonColor = Color(0xFFF0F2F1);
  static const _handleColor = Color(0xFFD5D8D6);

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _radius = _defaultRadius;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleController.text = initial.title;
      _descriptionController.text = initial.description ?? '';
      _radius = initial.radius.clamp(_minRadius, _maxRadius).toDouble();
    }
    // Riabilita/disabilita il bottone Salva mentre l'utente digita.
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  String _formatRadius(double radius) =>
      radius >= 1000 ? '1 km' : '${radius.round()} m';

  String get _formattedCoords {
    final lat = widget.position.latitude.toStringAsFixed(4);
    final lng = widget.position.longitude.toStringAsFixed(4);
    return '$lat, $lng';
  }

  void _save() {
    final description = _descriptionController.text.trim();
    Navigator.of(context).pop(
      ReminderDraft(
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        latitude: widget.position.latitude,
        longitude: widget.position.longitude,
        radius: _radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teal = theme.colorScheme.primary;

    return Padding(
      // Solleva il contenuto sopra la tastiera.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.initial == null
                      ? 'Nuovo promemoria'
                      : 'Modifica promemoria',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: 'Chiudi',
                style: IconButton.styleFrom(
                  backgroundColor: _closeButtonColor,
                  foregroundColor: const Color(0xFF212121),
                  fixedSize: const Size.square(36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _coordsBoxColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.place, color: teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POSIZIONE DAL PIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: teal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formattedCoords,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.lock_outline,
                    size: 20, color: Color(0xFF757575)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Titolo *',
              hintText: 'Es. Comprare il latte',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 2,
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Descrizione (opzionale)',
              hintText: 'Aggiungi una nota…',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.adjust, size: 20, color: Color(0xFF757575)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Raggio di attivazione',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                _formatRadius(_radius),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: teal,
                ),
              ),
            ],
          ),
          Slider(
            value: _radius,
            min: _minRadius,
            max: _maxRadius,
            divisions: 19,
            onChanged: (value) => setState(() => _radius = value),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50 m',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
              Text('1 km',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _canSave ? _save : null,
            icon: const Icon(Icons.check),
            label: const Text('Salva promemoria'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
