class EmergencyEventEntity {
  final String id;
  final String careRecipientId;
  final DateTime triggeredAt;
  final String triggerType;
  final DateTime? cancelledAt;
  final String? selectedAction;
  final String actionStatus;
  final String? notes;
  final DateTime createdAt;

  const EmergencyEventEntity({
    required this.id,
    required this.careRecipientId,
    required this.triggeredAt,
    required this.triggerType,
    this.cancelledAt,
    this.selectedAction,
    required this.actionStatus,
    this.notes,
    required this.createdAt,
  });

  EmergencyEventEntity copyWith({
    String? id,
    String? careRecipientId,
    DateTime? triggeredAt,
    String? triggerType,
    DateTime? cancelledAt,
    String? selectedAction,
    String? actionStatus,
    String? notes,
    DateTime? createdAt,
  }) {
    return EmergencyEventEntity(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      triggerType: triggerType ?? this.triggerType,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      selectedAction: selectedAction ?? this.selectedAction,
      actionStatus: actionStatus ?? this.actionStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
