class AppointmentEntity {
  final String id;
  final String careRecipientId;
  final String? providerOrFacility;
  final String? purpose;
  final DateTime scheduledAt;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentEntity({
    required this.id,
    required this.careRecipientId,
    this.providerOrFacility,
    this.purpose,
    required this.scheduledAt,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  AppointmentEntity copyWith({
    String? id,
    String? careRecipientId,
    String? providerOrFacility,
    String? purpose,
    DateTime? scheduledAt,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      providerOrFacility: providerOrFacility ?? this.providerOrFacility,
      purpose: purpose ?? this.purpose,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
