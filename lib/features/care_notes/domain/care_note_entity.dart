class CareNoteEntity {
  final String id;
  final String careRecipientId;
  final DateTime observedAt;
  final DateTime recordedAt;
  final String originalText;
  final String? structuredSummary;
  final String sourceType;
  final String reviewStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CareNoteEntity({
    required this.id,
    required this.careRecipientId,
    required this.observedAt,
    required this.recordedAt,
    required this.originalText,
    this.structuredSummary,
    required this.sourceType,
    required this.reviewStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  CareNoteEntity copyWith({
    String? id,
    String? careRecipientId,
    DateTime? observedAt,
    DateTime? recordedAt,
    String? originalText,
    String? structuredSummary,
    String? sourceType,
    String? reviewStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CareNoteEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      observedAt: observedAt ?? this.observedAt,
      recordedAt: recordedAt ?? this.recordedAt,
      originalText: originalText ?? this.originalText,
      structuredSummary: structuredSummary ?? this.structuredSummary,
      sourceType: sourceType ?? this.sourceType,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
