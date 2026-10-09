class CareRecipientEntity {
  final String id;
  final String displayName;
  final DateTime? dateOfBirth;
  final String? allergies;
  final String? importantNotes;
  final String? emergencyInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CareRecipientEntity({
    required this.id,
    required this.displayName,
    this.dateOfBirth,
    this.allergies,
    this.importantNotes,
    this.emergencyInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  CareRecipientEntity copyWith({
    String? id,
    String? displayName,
    DateTime? dateOfBirth,
    String? allergies,
    String? importantNotes,
    String? emergencyInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CareRecipientEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      allergies: allergies ?? this.allergies,
      importantNotes: importantNotes ?? this.importantNotes,
      emergencyInfo: emergencyInfo ?? this.emergencyInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
