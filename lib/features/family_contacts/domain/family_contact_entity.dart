class FamilyContactEntity {
  final String id;
  final String careRecipientId;
  final String displayName;
  final String? relationship;
  final String phoneNumber;
  final bool isEmergencyContact;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyContactEntity({
    required this.id,
    required this.careRecipientId,
    required this.displayName,
    this.relationship,
    required this.phoneNumber,
    required this.isEmergencyContact,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  FamilyContactEntity copyWith({
    String? id,
    String? careRecipientId,
    String? displayName,
    String? relationship,
    String? phoneNumber,
    bool? isEmergencyContact,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyContactEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      displayName: displayName ?? this.displayName,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
