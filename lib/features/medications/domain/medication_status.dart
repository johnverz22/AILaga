enum MedicationStatus {
  pending,
  taken,
  skipped,
  notConfirmed;

  String get databaseValue {
    switch (this) {
      case MedicationStatus.pending: return 'pending';
      case MedicationStatus.taken: return 'taken';
      case MedicationStatus.skipped: return 'skipped';
      case MedicationStatus.notConfirmed: return 'not_confirmed';
    }
  }

  static MedicationStatus fromDatabaseValue(String value) {
    switch (value) {
      case 'pending': return MedicationStatus.pending;
      case 'taken': return MedicationStatus.taken;
      case 'skipped': return MedicationStatus.skipped;
      case 'not_confirmed': return MedicationStatus.notConfirmed;
      default: return MedicationStatus.pending;
    }
  }

  String get displayLabel {
    switch (this) {
      case MedicationStatus.pending: return 'Pending';
      case MedicationStatus.taken: return 'Taken';
      case MedicationStatus.skipped: return 'Skipped';
      case MedicationStatus.notConfirmed: return 'Not Confirmed';
    }
  }
}
