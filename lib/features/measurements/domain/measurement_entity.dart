import 'measurement_type.dart';

class MeasurementEntity {
  final String id;
  final String careRecipientId;
  final MeasurementType measurementType;
  final double value1;
  final double? value2;
  final String unit;
  final DateTime measuredAt;
  final DateTime recordedAt;
  final String sourceType;
  final String? sourceLabel;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementEntity({
    required this.id,
    required this.careRecipientId,
    required this.measurementType,
    required this.value1,
    this.value2,
    required this.unit,
    required this.measuredAt,
    required this.recordedAt,
    required this.sourceType,
    this.sourceLabel,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  MeasurementEntity copyWith({
    String? id,
    String? careRecipientId,
    MeasurementType? measurementType,
    double? value1,
    double? value2,
    String? unit,
    DateTime? measuredAt,
    DateTime? recordedAt,
    String? sourceType,
    String? sourceLabel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeasurementEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      measurementType: measurementType ?? this.measurementType,
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      unit: unit ?? this.unit,
      measuredAt: measuredAt ?? this.measuredAt,
      recordedAt: recordedAt ?? this.recordedAt,
      sourceType: sourceType ?? this.sourceType,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
