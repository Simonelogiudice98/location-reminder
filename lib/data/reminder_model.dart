import 'package:hive/hive.dart';

/// Modello dati di un promemoria geolocalizzato.
class Reminder {
  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;

  /// Raggio di attivazione in metri.
  final double radius;
  final DateTime createdAt;
  final bool isActive;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.radius = 200,
    required this.createdAt,
    this.isActive = true,
  });

  Reminder copyWith({
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Adapter Hive scritto a mano (niente codegen).
///
/// Serializza i campi preceduti dal loro indice, così campi aggiunti in
/// versioni future possono essere letti con un default senza migrare i
/// dati già salvati.
class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.latitude);
    writer.writeByte(4);
    writer.write(obj.longitude);
    writer.writeByte(5);
    writer.write(obj.radius);
    writer.writeByte(6);
    writer.write(obj.createdAt);
    writer.writeByte(7);
    writer.write(obj.isActive);
  }

  @override
  Reminder read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      radius: fields[5] as double? ?? 200,
      createdAt: fields[6] as DateTime,
      isActive: fields[7] as bool? ?? true,
    );
  }
}
