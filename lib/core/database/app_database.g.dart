// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CareRecipientsTable extends CareRecipients
    with TableInfo<$CareRecipientsTable, CareRecipient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareRecipientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _allergiesMeta =
      const VerificationMeta('allergies');
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
      'allergies', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importantNotesMeta =
      const VerificationMeta('importantNotes');
  @override
  late final GeneratedColumn<String> importantNotes = GeneratedColumn<String>(
      'important_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emergencyInfoMeta =
      const VerificationMeta('emergencyInfo');
  @override
  late final GeneratedColumn<String> emergencyInfo = GeneratedColumn<String>(
      'emergency_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        dateOfBirth,
        allergies,
        importantNotes,
        emergencyInfo,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_recipients';
  @override
  VerificationContext validateIntegrity(Insertable<CareRecipient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('allergies')) {
      context.handle(_allergiesMeta,
          allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta));
    }
    if (data.containsKey('important_notes')) {
      context.handle(
          _importantNotesMeta,
          importantNotes.isAcceptableOrUnknown(
              data['important_notes']!, _importantNotesMeta));
    }
    if (data.containsKey('emergency_info')) {
      context.handle(
          _emergencyInfoMeta,
          emergencyInfo.isAcceptableOrUnknown(
              data['emergency_info']!, _emergencyInfoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareRecipient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareRecipient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      allergies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allergies']),
      importantNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}important_notes']),
      emergencyInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emergency_info']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CareRecipientsTable createAlias(String alias) {
    return $CareRecipientsTable(attachedDatabase, alias);
  }
}

class CareRecipient extends DataClass implements Insertable<CareRecipient> {
  final String id;
  final String displayName;
  final DateTime? dateOfBirth;
  final String? allergies;
  final String? importantNotes;
  final String? emergencyInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CareRecipient(
      {required this.id,
      required this.displayName,
      this.dateOfBirth,
      this.allergies,
      this.importantNotes,
      this.emergencyInfo,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    if (!nullToAbsent || importantNotes != null) {
      map['important_notes'] = Variable<String>(importantNotes);
    }
    if (!nullToAbsent || emergencyInfo != null) {
      map['emergency_info'] = Variable<String>(emergencyInfo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CareRecipientsCompanion toCompanion(bool nullToAbsent) {
    return CareRecipientsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      importantNotes: importantNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(importantNotes),
      emergencyInfo: emergencyInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyInfo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CareRecipient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareRecipient(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      importantNotes: serializer.fromJson<String?>(json['importantNotes']),
      emergencyInfo: serializer.fromJson<String?>(json['emergencyInfo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'allergies': serializer.toJson<String?>(allergies),
      'importantNotes': serializer.toJson<String?>(importantNotes),
      'emergencyInfo': serializer.toJson<String?>(emergencyInfo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CareRecipient copyWith(
          {String? id,
          String? displayName,
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<String?> allergies = const Value.absent(),
          Value<String?> importantNotes = const Value.absent(),
          Value<String?> emergencyInfo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CareRecipient(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        allergies: allergies.present ? allergies.value : this.allergies,
        importantNotes:
            importantNotes.present ? importantNotes.value : this.importantNotes,
        emergencyInfo:
            emergencyInfo.present ? emergencyInfo.value : this.emergencyInfo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CareRecipient copyWithCompanion(CareRecipientsCompanion data) {
    return CareRecipient(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      importantNotes: data.importantNotes.present
          ? data.importantNotes.value
          : this.importantNotes,
      emergencyInfo: data.emergencyInfo.present
          ? data.emergencyInfo.value
          : this.emergencyInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareRecipient(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('allergies: $allergies, ')
          ..write('importantNotes: $importantNotes, ')
          ..write('emergencyInfo: $emergencyInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, dateOfBirth, allergies,
      importantNotes, emergencyInfo, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareRecipient &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.allergies == this.allergies &&
          other.importantNotes == this.importantNotes &&
          other.emergencyInfo == this.emergencyInfo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CareRecipientsCompanion extends UpdateCompanion<CareRecipient> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> allergies;
  final Value<String?> importantNotes;
  final Value<String?> emergencyInfo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CareRecipientsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.allergies = const Value.absent(),
    this.importantNotes = const Value.absent(),
    this.emergencyInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareRecipientsCompanion.insert({
    required String id,
    required String displayName,
    this.dateOfBirth = const Value.absent(),
    this.allergies = const Value.absent(),
    this.importantNotes = const Value.absent(),
    this.emergencyInfo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CareRecipient> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? allergies,
    Expression<String>? importantNotes,
    Expression<String>? emergencyInfo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (allergies != null) 'allergies': allergies,
      if (importantNotes != null) 'important_notes': importantNotes,
      if (emergencyInfo != null) 'emergency_info': emergencyInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareRecipientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<DateTime?>? dateOfBirth,
      Value<String?>? allergies,
      Value<String?>? importantNotes,
      Value<String?>? emergencyInfo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CareRecipientsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      allergies: allergies ?? this.allergies,
      importantNotes: importantNotes ?? this.importantNotes,
      emergencyInfo: emergencyInfo ?? this.emergencyInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (importantNotes.present) {
      map['important_notes'] = Variable<String>(importantNotes.value);
    }
    if (emergencyInfo.present) {
      map['emergency_info'] = Variable<String>(emergencyInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareRecipientsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('allergies: $allergies, ')
          ..write('importantNotes: $importantNotes, ')
          ..write('emergencyInfo: $emergencyInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyContactsTable extends FamilyContacts
    with TableInfo<$FamilyContactsTable, FamilyContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _relationshipMeta =
      const VerificationMeta('relationship');
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
      'relationship', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isEmergencyContactMeta =
      const VerificationMeta('isEmergencyContact');
  @override
  late final GeneratedColumn<bool> isEmergencyContact = GeneratedColumn<bool>(
      'is_emergency_contact', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_emergency_contact" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        displayName,
        relationship,
        phoneNumber,
        isEmergencyContact,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_contacts';
  @override
  VerificationContext validateIntegrity(Insertable<FamilyContact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('relationship')) {
      context.handle(
          _relationshipMeta,
          relationship.isAcceptableOrUnknown(
              data['relationship']!, _relationshipMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('is_emergency_contact')) {
      context.handle(
          _isEmergencyContactMeta,
          isEmergencyContact.isAcceptableOrUnknown(
              data['is_emergency_contact']!, _isEmergencyContactMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyContact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      relationship: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relationship']),
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      isEmergencyContact: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_emergency_contact'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FamilyContactsTable createAlias(String alias) {
    return $FamilyContactsTable(attachedDatabase, alias);
  }
}

class FamilyContact extends DataClass implements Insertable<FamilyContact> {
  final String id;
  final String careRecipientId;
  final String displayName;
  final String? relationship;
  final String phoneNumber;
  final bool isEmergencyContact;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FamilyContact(
      {required this.id,
      required this.careRecipientId,
      required this.displayName,
      this.relationship,
      required this.phoneNumber,
      required this.isEmergencyContact,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || relationship != null) {
      map['relationship'] = Variable<String>(relationship);
    }
    map['phone_number'] = Variable<String>(phoneNumber);
    map['is_emergency_contact'] = Variable<bool>(isEmergencyContact);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FamilyContactsCompanion toCompanion(bool nullToAbsent) {
    return FamilyContactsCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      displayName: Value(displayName),
      relationship: relationship == null && nullToAbsent
          ? const Value.absent()
          : Value(relationship),
      phoneNumber: Value(phoneNumber),
      isEmergencyContact: Value(isEmergencyContact),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FamilyContact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyContact(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      relationship: serializer.fromJson<String?>(json['relationship']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      isEmergencyContact: serializer.fromJson<bool>(json['isEmergencyContact']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'displayName': serializer.toJson<String>(displayName),
      'relationship': serializer.toJson<String?>(relationship),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'isEmergencyContact': serializer.toJson<bool>(isEmergencyContact),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FamilyContact copyWith(
          {String? id,
          String? careRecipientId,
          String? displayName,
          Value<String?> relationship = const Value.absent(),
          String? phoneNumber,
          bool? isEmergencyContact,
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FamilyContact(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        displayName: displayName ?? this.displayName,
        relationship:
            relationship.present ? relationship.value : this.relationship,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FamilyContact copyWithCompanion(FamilyContactsCompanion data) {
    return FamilyContact(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      isEmergencyContact: data.isEmergencyContact.present
          ? data.isEmergencyContact.value
          : this.isEmergencyContact,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyContact(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isEmergencyContact: $isEmergencyContact, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      careRecipientId,
      displayName,
      relationship,
      phoneNumber,
      isEmergencyContact,
      sortOrder,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyContact &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.displayName == this.displayName &&
          other.relationship == this.relationship &&
          other.phoneNumber == this.phoneNumber &&
          other.isEmergencyContact == this.isEmergencyContact &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FamilyContactsCompanion extends UpdateCompanion<FamilyContact> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<String> displayName;
  final Value<String?> relationship;
  final Value<String> phoneNumber;
  final Value<bool> isEmergencyContact;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FamilyContactsCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.isEmergencyContact = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyContactsCompanion.insert({
    required String id,
    required String careRecipientId,
    required String displayName,
    this.relationship = const Value.absent(),
    required String phoneNumber,
    this.isEmergencyContact = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        displayName = Value(displayName),
        phoneNumber = Value(phoneNumber),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FamilyContact> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<String>? displayName,
    Expression<String>? relationship,
    Expression<String>? phoneNumber,
    Expression<bool>? isEmergencyContact,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (displayName != null) 'display_name': displayName,
      if (relationship != null) 'relationship': relationship,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isEmergencyContact != null)
        'is_emergency_contact': isEmergencyContact,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyContactsCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<String>? displayName,
      Value<String?>? relationship,
      Value<String>? phoneNumber,
      Value<bool>? isEmergencyContact,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FamilyContactsCompanion(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      displayName: displayName ?? this.displayName,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (isEmergencyContact.present) {
      map['is_emergency_contact'] = Variable<bool>(isEmergencyContact.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyContactsCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isEmergencyContact: $isEmergencyContact, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationSchedulesTable extends MedicationSchedules
    with TableInfo<$MedicationSchedulesTable, MedicationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _medicationNameMeta =
      const VerificationMeta('medicationName');
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
      'medication_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 300),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _prescribedInstructionsMeta =
      const VerificationMeta('prescribedInstructions');
  @override
  late final GeneratedColumn<String> prescribedInstructions =
      GeneratedColumn<String>('prescribed_instructions', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduleTimesMeta =
      const VerificationMeta('scheduleTimes');
  @override
  late final GeneratedColumn<String> scheduleTimes = GeneratedColumn<String>(
      'schedule_times', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        medicationName,
        prescribedInstructions,
        scheduleTimes,
        startDate,
        endDate,
        notes,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<MedicationSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
          _medicationNameMeta,
          medicationName.isAcceptableOrUnknown(
              data['medication_name']!, _medicationNameMeta));
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('prescribed_instructions')) {
      context.handle(
          _prescribedInstructionsMeta,
          prescribedInstructions.isAcceptableOrUnknown(
              data['prescribed_instructions']!, _prescribedInstructionsMeta));
    }
    if (data.containsKey('schedule_times')) {
      context.handle(
          _scheduleTimesMeta,
          scheduleTimes.isAcceptableOrUnknown(
              data['schedule_times']!, _scheduleTimesMeta));
    } else if (isInserting) {
      context.missing(_scheduleTimesMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      medicationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medication_name'])!,
      prescribedInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prescribed_instructions']),
      scheduleTimes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_times'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MedicationSchedulesTable createAlias(String alias) {
    return $MedicationSchedulesTable(attachedDatabase, alias);
  }
}

class MedicationSchedule extends DataClass
    implements Insertable<MedicationSchedule> {
  final String id;
  final String careRecipientId;
  final String medicationName;
  final String? prescribedInstructions;
  final String scheduleTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MedicationSchedule(
      {required this.id,
      required this.careRecipientId,
      required this.medicationName,
      this.prescribedInstructions,
      required this.scheduleTimes,
      required this.startDate,
      this.endDate,
      this.notes,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['medication_name'] = Variable<String>(medicationName);
    if (!nullToAbsent || prescribedInstructions != null) {
      map['prescribed_instructions'] = Variable<String>(prescribedInstructions);
    }
    map['schedule_times'] = Variable<String>(scheduleTimes);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MedicationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MedicationSchedulesCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      medicationName: Value(medicationName),
      prescribedInstructions: prescribedInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(prescribedInstructions),
      scheduleTimes: Value(scheduleTimes),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MedicationSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationSchedule(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      prescribedInstructions:
          serializer.fromJson<String?>(json['prescribedInstructions']),
      scheduleTimes: serializer.fromJson<String>(json['scheduleTimes']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'medicationName': serializer.toJson<String>(medicationName),
      'prescribedInstructions':
          serializer.toJson<String?>(prescribedInstructions),
      'scheduleTimes': serializer.toJson<String>(scheduleTimes),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MedicationSchedule copyWith(
          {String? id,
          String? careRecipientId,
          String? medicationName,
          Value<String?> prescribedInstructions = const Value.absent(),
          String? scheduleTimes,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MedicationSchedule(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        medicationName: medicationName ?? this.medicationName,
        prescribedInstructions: prescribedInstructions.present
            ? prescribedInstructions.value
            : this.prescribedInstructions,
        scheduleTimes: scheduleTimes ?? this.scheduleTimes,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        notes: notes.present ? notes.value : this.notes,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MedicationSchedule copyWithCompanion(MedicationSchedulesCompanion data) {
    return MedicationSchedule(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      prescribedInstructions: data.prescribedInstructions.present
          ? data.prescribedInstructions.value
          : this.prescribedInstructions,
      scheduleTimes: data.scheduleTimes.present
          ? data.scheduleTimes.value
          : this.scheduleTimes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedule(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('medicationName: $medicationName, ')
          ..write('prescribedInstructions: $prescribedInstructions, ')
          ..write('scheduleTimes: $scheduleTimes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      careRecipientId,
      medicationName,
      prescribedInstructions,
      scheduleTimes,
      startDate,
      endDate,
      notes,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationSchedule &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.medicationName == this.medicationName &&
          other.prescribedInstructions == this.prescribedInstructions &&
          other.scheduleTimes == this.scheduleTimes &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MedicationSchedulesCompanion extends UpdateCompanion<MedicationSchedule> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<String> medicationName;
  final Value<String?> prescribedInstructions;
  final Value<String> scheduleTimes;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MedicationSchedulesCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.prescribedInstructions = const Value.absent(),
    this.scheduleTimes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationSchedulesCompanion.insert({
    required String id,
    required String careRecipientId,
    required String medicationName,
    this.prescribedInstructions = const Value.absent(),
    required String scheduleTimes,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        medicationName = Value(medicationName),
        scheduleTimes = Value(scheduleTimes),
        startDate = Value(startDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MedicationSchedule> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<String>? medicationName,
    Expression<String>? prescribedInstructions,
    Expression<String>? scheduleTimes,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (medicationName != null) 'medication_name': medicationName,
      if (prescribedInstructions != null)
        'prescribed_instructions': prescribedInstructions,
      if (scheduleTimes != null) 'schedule_times': scheduleTimes,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationSchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<String>? medicationName,
      Value<String?>? prescribedInstructions,
      Value<String>? scheduleTimes,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<String?>? notes,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MedicationSchedulesCompanion(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      medicationName: medicationName ?? this.medicationName,
      prescribedInstructions:
          prescribedInstructions ?? this.prescribedInstructions,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (prescribedInstructions.present) {
      map['prescribed_instructions'] =
          Variable<String>(prescribedInstructions.value);
    }
    if (scheduleTimes.present) {
      map['schedule_times'] = Variable<String>(scheduleTimes.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('medicationName: $medicationName, ')
          ..write('prescribedInstructions: $prescribedInstructions, ')
          ..write('scheduleTimes: $scheduleTimes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationOccurrencesTable extends MedicationOccurrences
    with TableInfo<$MedicationOccurrencesTable, MedicationOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicationScheduleIdMeta =
      const VerificationMeta('medicationScheduleId');
  @override
  late final GeneratedColumn<String> medicationScheduleId =
      GeneratedColumn<String>(
          'medication_schedule_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES medication_schedules (id)'));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _statusUpdatedAtMeta =
      const VerificationMeta('statusUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> statusUpdatedAt =
      GeneratedColumn<DateTime>('status_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusSourceMeta =
      const VerificationMeta('statusSource');
  @override
  late final GeneratedColumn<String> statusSource = GeneratedColumn<String>(
      'status_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _statusNoteMeta =
      const VerificationMeta('statusNote');
  @override
  late final GeneratedColumn<String> statusNote = GeneratedColumn<String>(
      'status_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordedByLabelMeta =
      const VerificationMeta('recordedByLabel');
  @override
  late final GeneratedColumn<String> recordedByLabel = GeneratedColumn<String>(
      'recorded_by_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        medicationScheduleId,
        scheduledAt,
        status,
        statusUpdatedAt,
        statusSource,
        statusNote,
        recordedByLabel,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_occurrences';
  @override
  VerificationContext validateIntegrity(
      Insertable<MedicationOccurrence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_schedule_id')) {
      context.handle(
          _medicationScheduleIdMeta,
          medicationScheduleId.isAcceptableOrUnknown(
              data['medication_schedule_id']!, _medicationScheduleIdMeta));
    } else if (isInserting) {
      context.missing(_medicationScheduleIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('status_updated_at')) {
      context.handle(
          _statusUpdatedAtMeta,
          statusUpdatedAt.isAcceptableOrUnknown(
              data['status_updated_at']!, _statusUpdatedAtMeta));
    }
    if (data.containsKey('status_source')) {
      context.handle(
          _statusSourceMeta,
          statusSource.isAcceptableOrUnknown(
              data['status_source']!, _statusSourceMeta));
    }
    if (data.containsKey('status_note')) {
      context.handle(
          _statusNoteMeta,
          statusNote.isAcceptableOrUnknown(
              data['status_note']!, _statusNoteMeta));
    }
    if (data.containsKey('recorded_by_label')) {
      context.handle(
          _recordedByLabelMeta,
          recordedByLabel.isAcceptableOrUnknown(
              data['recorded_by_label']!, _recordedByLabelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {medicationScheduleId, scheduledAt},
      ];
  @override
  MedicationOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationOccurrence(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      medicationScheduleId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medication_schedule_id'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      statusUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}status_updated_at']),
      statusSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status_source'])!,
      statusNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status_note']),
      recordedByLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recorded_by_label']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicationOccurrencesTable createAlias(String alias) {
    return $MedicationOccurrencesTable(attachedDatabase, alias);
  }
}

class MedicationOccurrence extends DataClass
    implements Insertable<MedicationOccurrence> {
  final String id;
  final String medicationScheduleId;
  final DateTime scheduledAt;
  final String status;
  final DateTime? statusUpdatedAt;
  final String statusSource;
  final String? statusNote;
  final String? recordedByLabel;
  final DateTime createdAt;
  const MedicationOccurrence(
      {required this.id,
      required this.medicationScheduleId,
      required this.scheduledAt,
      required this.status,
      this.statusUpdatedAt,
      required this.statusSource,
      this.statusNote,
      this.recordedByLabel,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_schedule_id'] = Variable<String>(medicationScheduleId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || statusUpdatedAt != null) {
      map['status_updated_at'] = Variable<DateTime>(statusUpdatedAt);
    }
    map['status_source'] = Variable<String>(statusSource);
    if (!nullToAbsent || statusNote != null) {
      map['status_note'] = Variable<String>(statusNote);
    }
    if (!nullToAbsent || recordedByLabel != null) {
      map['recorded_by_label'] = Variable<String>(recordedByLabel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return MedicationOccurrencesCompanion(
      id: Value(id),
      medicationScheduleId: Value(medicationScheduleId),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      statusUpdatedAt: statusUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusUpdatedAt),
      statusSource: Value(statusSource),
      statusNote: statusNote == null && nullToAbsent
          ? const Value.absent()
          : Value(statusNote),
      recordedByLabel: recordedByLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedByLabel),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationOccurrence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationOccurrence(
      id: serializer.fromJson<String>(json['id']),
      medicationScheduleId:
          serializer.fromJson<String>(json['medicationScheduleId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      statusUpdatedAt: serializer.fromJson<DateTime?>(json['statusUpdatedAt']),
      statusSource: serializer.fromJson<String>(json['statusSource']),
      statusNote: serializer.fromJson<String?>(json['statusNote']),
      recordedByLabel: serializer.fromJson<String?>(json['recordedByLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationScheduleId': serializer.toJson<String>(medicationScheduleId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'statusUpdatedAt': serializer.toJson<DateTime?>(statusUpdatedAt),
      'statusSource': serializer.toJson<String>(statusSource),
      'statusNote': serializer.toJson<String?>(statusNote),
      'recordedByLabel': serializer.toJson<String?>(recordedByLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationOccurrence copyWith(
          {String? id,
          String? medicationScheduleId,
          DateTime? scheduledAt,
          String? status,
          Value<DateTime?> statusUpdatedAt = const Value.absent(),
          String? statusSource,
          Value<String?> statusNote = const Value.absent(),
          Value<String?> recordedByLabel = const Value.absent(),
          DateTime? createdAt}) =>
      MedicationOccurrence(
        id: id ?? this.id,
        medicationScheduleId: medicationScheduleId ?? this.medicationScheduleId,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        statusUpdatedAt: statusUpdatedAt.present
            ? statusUpdatedAt.value
            : this.statusUpdatedAt,
        statusSource: statusSource ?? this.statusSource,
        statusNote: statusNote.present ? statusNote.value : this.statusNote,
        recordedByLabel: recordedByLabel.present
            ? recordedByLabel.value
            : this.recordedByLabel,
        createdAt: createdAt ?? this.createdAt,
      );
  MedicationOccurrence copyWithCompanion(MedicationOccurrencesCompanion data) {
    return MedicationOccurrence(
      id: data.id.present ? data.id.value : this.id,
      medicationScheduleId: data.medicationScheduleId.present
          ? data.medicationScheduleId.value
          : this.medicationScheduleId,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      statusUpdatedAt: data.statusUpdatedAt.present
          ? data.statusUpdatedAt.value
          : this.statusUpdatedAt,
      statusSource: data.statusSource.present
          ? data.statusSource.value
          : this.statusSource,
      statusNote:
          data.statusNote.present ? data.statusNote.value : this.statusNote,
      recordedByLabel: data.recordedByLabel.present
          ? data.recordedByLabel.value
          : this.recordedByLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationOccurrence(')
          ..write('id: $id, ')
          ..write('medicationScheduleId: $medicationScheduleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt, ')
          ..write('statusSource: $statusSource, ')
          ..write('statusNote: $statusNote, ')
          ..write('recordedByLabel: $recordedByLabel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, medicationScheduleId, scheduledAt, status,
      statusUpdatedAt, statusSource, statusNote, recordedByLabel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationOccurrence &&
          other.id == this.id &&
          other.medicationScheduleId == this.medicationScheduleId &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.statusUpdatedAt == this.statusUpdatedAt &&
          other.statusSource == this.statusSource &&
          other.statusNote == this.statusNote &&
          other.recordedByLabel == this.recordedByLabel &&
          other.createdAt == this.createdAt);
}

class MedicationOccurrencesCompanion
    extends UpdateCompanion<MedicationOccurrence> {
  final Value<String> id;
  final Value<String> medicationScheduleId;
  final Value<DateTime> scheduledAt;
  final Value<String> status;
  final Value<DateTime?> statusUpdatedAt;
  final Value<String> statusSource;
  final Value<String?> statusNote;
  final Value<String?> recordedByLabel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicationOccurrencesCompanion({
    this.id = const Value.absent(),
    this.medicationScheduleId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.statusUpdatedAt = const Value.absent(),
    this.statusSource = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.recordedByLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationOccurrencesCompanion.insert({
    required String id,
    required String medicationScheduleId,
    required DateTime scheduledAt,
    this.status = const Value.absent(),
    this.statusUpdatedAt = const Value.absent(),
    this.statusSource = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.recordedByLabel = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        medicationScheduleId = Value(medicationScheduleId),
        scheduledAt = Value(scheduledAt),
        createdAt = Value(createdAt);
  static Insertable<MedicationOccurrence> custom({
    Expression<String>? id,
    Expression<String>? medicationScheduleId,
    Expression<DateTime>? scheduledAt,
    Expression<String>? status,
    Expression<DateTime>? statusUpdatedAt,
    Expression<String>? statusSource,
    Expression<String>? statusNote,
    Expression<String>? recordedByLabel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationScheduleId != null)
        'medication_schedule_id': medicationScheduleId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (statusUpdatedAt != null) 'status_updated_at': statusUpdatedAt,
      if (statusSource != null) 'status_source': statusSource,
      if (statusNote != null) 'status_note': statusNote,
      if (recordedByLabel != null) 'recorded_by_label': recordedByLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationOccurrencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? medicationScheduleId,
      Value<DateTime>? scheduledAt,
      Value<String>? status,
      Value<DateTime?>? statusUpdatedAt,
      Value<String>? statusSource,
      Value<String?>? statusNote,
      Value<String?>? recordedByLabel,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MedicationOccurrencesCompanion(
      id: id ?? this.id,
      medicationScheduleId: medicationScheduleId ?? this.medicationScheduleId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusSource: statusSource ?? this.statusSource,
      statusNote: statusNote ?? this.statusNote,
      recordedByLabel: recordedByLabel ?? this.recordedByLabel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationScheduleId.present) {
      map['medication_schedule_id'] =
          Variable<String>(medicationScheduleId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusUpdatedAt.present) {
      map['status_updated_at'] = Variable<DateTime>(statusUpdatedAt.value);
    }
    if (statusSource.present) {
      map['status_source'] = Variable<String>(statusSource.value);
    }
    if (statusNote.present) {
      map['status_note'] = Variable<String>(statusNote.value);
    }
    if (recordedByLabel.present) {
      map['recorded_by_label'] = Variable<String>(recordedByLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('medicationScheduleId: $medicationScheduleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt, ')
          ..write('statusSource: $statusSource, ')
          ..write('statusNote: $statusNote, ')
          ..write('recordedByLabel: $recordedByLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementLogsTable extends MeasurementLogs
    with TableInfo<$MeasurementLogsTable, MeasurementLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _measurementTypeMeta =
      const VerificationMeta('measurementType');
  @override
  late final GeneratedColumn<String> measurementType = GeneratedColumn<String>(
      'measurement_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _value1Meta = const VerificationMeta('value1');
  @override
  late final GeneratedColumn<double> value1 = GeneratedColumn<double>(
      'value1', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _value2Meta = const VerificationMeta('value2');
  @override
  late final GeneratedColumn<double> value2 = GeneratedColumn<double>(
      'value2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _measuredAtMeta =
      const VerificationMeta('measuredAt');
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
      'measured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _sourceLabelMeta =
      const VerificationMeta('sourceLabel');
  @override
  late final GeneratedColumn<String> sourceLabel = GeneratedColumn<String>(
      'source_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        measurementType,
        value1,
        value2,
        unit,
        measuredAt,
        recordedAt,
        sourceType,
        sourceLabel,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_logs';
  @override
  VerificationContext validateIntegrity(Insertable<MeasurementLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('measurement_type')) {
      context.handle(
          _measurementTypeMeta,
          measurementType.isAcceptableOrUnknown(
              data['measurement_type']!, _measurementTypeMeta));
    } else if (isInserting) {
      context.missing(_measurementTypeMeta);
    }
    if (data.containsKey('value1')) {
      context.handle(_value1Meta,
          value1.isAcceptableOrUnknown(data['value1']!, _value1Meta));
    } else if (isInserting) {
      context.missing(_value1Meta);
    }
    if (data.containsKey('value2')) {
      context.handle(_value2Meta,
          value2.isAcceptableOrUnknown(data['value2']!, _value2Meta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
          _measuredAtMeta,
          measuredAt.isAcceptableOrUnknown(
              data['measured_at']!, _measuredAtMeta));
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('source_label')) {
      context.handle(
          _sourceLabelMeta,
          sourceLabel.isAcceptableOrUnknown(
              data['source_label']!, _sourceLabelMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      measurementType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}measurement_type'])!,
      value1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value1'])!,
      value2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value2']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      measuredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}measured_at'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_label']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MeasurementLogsTable createAlias(String alias) {
    return $MeasurementLogsTable(attachedDatabase, alias);
  }
}

class MeasurementLog extends DataClass implements Insertable<MeasurementLog> {
  final String id;
  final String careRecipientId;
  final String measurementType;
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
  const MeasurementLog(
      {required this.id,
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
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['measurement_type'] = Variable<String>(measurementType);
    map['value1'] = Variable<double>(value1);
    if (!nullToAbsent || value2 != null) {
      map['value2'] = Variable<double>(value2);
    }
    map['unit'] = Variable<String>(unit);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceLabel != null) {
      map['source_label'] = Variable<String>(sourceLabel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementLogsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementLogsCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      measurementType: Value(measurementType),
      value1: Value(value1),
      value2:
          value2 == null && nullToAbsent ? const Value.absent() : Value(value2),
      unit: Value(unit),
      measuredAt: Value(measuredAt),
      recordedAt: Value(recordedAt),
      sourceType: Value(sourceType),
      sourceLabel: sourceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLabel),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementLog(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      measurementType: serializer.fromJson<String>(json['measurementType']),
      value1: serializer.fromJson<double>(json['value1']),
      value2: serializer.fromJson<double?>(json['value2']),
      unit: serializer.fromJson<String>(json['unit']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceLabel: serializer.fromJson<String?>(json['sourceLabel']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'measurementType': serializer.toJson<String>(measurementType),
      'value1': serializer.toJson<double>(value1),
      'value2': serializer.toJson<double?>(value2),
      'unit': serializer.toJson<String>(unit),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceLabel': serializer.toJson<String?>(sourceLabel),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementLog copyWith(
          {String? id,
          String? careRecipientId,
          String? measurementType,
          double? value1,
          Value<double?> value2 = const Value.absent(),
          String? unit,
          DateTime? measuredAt,
          DateTime? recordedAt,
          String? sourceType,
          Value<String?> sourceLabel = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MeasurementLog(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        measurementType: measurementType ?? this.measurementType,
        value1: value1 ?? this.value1,
        value2: value2.present ? value2.value : this.value2,
        unit: unit ?? this.unit,
        measuredAt: measuredAt ?? this.measuredAt,
        recordedAt: recordedAt ?? this.recordedAt,
        sourceType: sourceType ?? this.sourceType,
        sourceLabel: sourceLabel.present ? sourceLabel.value : this.sourceLabel,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MeasurementLog copyWithCompanion(MeasurementLogsCompanion data) {
    return MeasurementLog(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      measurementType: data.measurementType.present
          ? data.measurementType.value
          : this.measurementType,
      value1: data.value1.present ? data.value1.value : this.value1,
      value2: data.value2.present ? data.value2.value : this.value2,
      unit: data.unit.present ? data.unit.value : this.unit,
      measuredAt:
          data.measuredAt.present ? data.measuredAt.value : this.measuredAt,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceLabel:
          data.sourceLabel.present ? data.sourceLabel.value : this.sourceLabel,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementLog(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('measurementType: $measurementType, ')
          ..write('value1: $value1, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      careRecipientId,
      measurementType,
      value1,
      value2,
      unit,
      measuredAt,
      recordedAt,
      sourceType,
      sourceLabel,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementLog &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.measurementType == this.measurementType &&
          other.value1 == this.value1 &&
          other.value2 == this.value2 &&
          other.unit == this.unit &&
          other.measuredAt == this.measuredAt &&
          other.recordedAt == this.recordedAt &&
          other.sourceType == this.sourceType &&
          other.sourceLabel == this.sourceLabel &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MeasurementLogsCompanion extends UpdateCompanion<MeasurementLog> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<String> measurementType;
  final Value<double> value1;
  final Value<double?> value2;
  final Value<String> unit;
  final Value<DateTime> measuredAt;
  final Value<DateTime> recordedAt;
  final Value<String> sourceType;
  final Value<String?> sourceLabel;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeasurementLogsCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.measurementType = const Value.absent(),
    this.value1 = const Value.absent(),
    this.value2 = const Value.absent(),
    this.unit = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceLabel = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementLogsCompanion.insert({
    required String id,
    required String careRecipientId,
    required String measurementType,
    required double value1,
    this.value2 = const Value.absent(),
    required String unit,
    required DateTime measuredAt,
    required DateTime recordedAt,
    this.sourceType = const Value.absent(),
    this.sourceLabel = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        measurementType = Value(measurementType),
        value1 = Value(value1),
        unit = Value(unit),
        measuredAt = Value(measuredAt),
        recordedAt = Value(recordedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MeasurementLog> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<String>? measurementType,
    Expression<double>? value1,
    Expression<double>? value2,
    Expression<String>? unit,
    Expression<DateTime>? measuredAt,
    Expression<DateTime>? recordedAt,
    Expression<String>? sourceType,
    Expression<String>? sourceLabel,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (measurementType != null) 'measurement_type': measurementType,
      if (value1 != null) 'value1': value1,
      if (value2 != null) 'value2': value2,
      if (unit != null) 'unit': unit,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceLabel != null) 'source_label': sourceLabel,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<String>? measurementType,
      Value<double>? value1,
      Value<double?>? value2,
      Value<String>? unit,
      Value<DateTime>? measuredAt,
      Value<DateTime>? recordedAt,
      Value<String>? sourceType,
      Value<String?>? sourceLabel,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MeasurementLogsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (measurementType.present) {
      map['measurement_type'] = Variable<String>(measurementType.value);
    }
    if (value1.present) {
      map['value1'] = Variable<double>(value1.value);
    }
    if (value2.present) {
      map['value2'] = Variable<double>(value2.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceLabel.present) {
      map['source_label'] = Variable<String>(sourceLabel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementLogsCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('measurementType: $measurementType, ')
          ..write('value1: $value1, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _providerOrFacilityMeta =
      const VerificationMeta('providerOrFacility');
  @override
  late final GeneratedColumn<String> providerOrFacility =
      GeneratedColumn<String>('provider_or_facility', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scheduled'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        providerOrFacility,
        purpose,
        scheduledAt,
        notes,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(Insertable<Appointment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('provider_or_facility')) {
      context.handle(
          _providerOrFacilityMeta,
          providerOrFacility.isAcceptableOrUnknown(
              data['provider_or_facility']!, _providerOrFacilityMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      providerOrFacility: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}provider_or_facility']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final String id;
  final String careRecipientId;
  final String? providerOrFacility;
  final String? purpose;
  final DateTime scheduledAt;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Appointment(
      {required this.id,
      required this.careRecipientId,
      this.providerOrFacility,
      this.purpose,
      required this.scheduledAt,
      this.notes,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    if (!nullToAbsent || providerOrFacility != null) {
      map['provider_or_facility'] = Variable<String>(providerOrFacility);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      providerOrFacility: providerOrFacility == null && nullToAbsent
          ? const Value.absent()
          : Value(providerOrFacility),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      scheduledAt: Value(scheduledAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      providerOrFacility:
          serializer.fromJson<String?>(json['providerOrFacility']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'providerOrFacility': serializer.toJson<String?>(providerOrFacility),
      'purpose': serializer.toJson<String?>(purpose),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Appointment copyWith(
          {String? id,
          String? careRecipientId,
          Value<String?> providerOrFacility = const Value.absent(),
          Value<String?> purpose = const Value.absent(),
          DateTime? scheduledAt,
          Value<String?> notes = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Appointment(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        providerOrFacility: providerOrFacility.present
            ? providerOrFacility.value
            : this.providerOrFacility,
        purpose: purpose.present ? purpose.value : this.purpose,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      providerOrFacility: data.providerOrFacility.present
          ? data.providerOrFacility.value
          : this.providerOrFacility,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('providerOrFacility: $providerOrFacility, ')
          ..write('purpose: $purpose, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, careRecipientId, providerOrFacility,
      purpose, scheduledAt, notes, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.providerOrFacility == this.providerOrFacility &&
          other.purpose == this.purpose &&
          other.scheduledAt == this.scheduledAt &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<String?> providerOrFacility;
  final Value<String?> purpose;
  final Value<DateTime> scheduledAt;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.providerOrFacility = const Value.absent(),
    this.purpose = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    required String careRecipientId,
    this.providerOrFacility = const Value.absent(),
    this.purpose = const Value.absent(),
    required DateTime scheduledAt,
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        scheduledAt = Value(scheduledAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Appointment> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<String>? providerOrFacility,
    Expression<String>? purpose,
    Expression<DateTime>? scheduledAt,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (providerOrFacility != null)
        'provider_or_facility': providerOrFacility,
      if (purpose != null) 'purpose': purpose,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<String?>? providerOrFacility,
      Value<String?>? purpose,
      Value<DateTime>? scheduledAt,
      Value<String?>? notes,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      providerOrFacility: providerOrFacility ?? this.providerOrFacility,
      purpose: purpose ?? this.purpose,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (providerOrFacility.present) {
      map['provider_or_facility'] = Variable<String>(providerOrFacility.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('providerOrFacility: $providerOrFacility, ')
          ..write('purpose: $purpose, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareNotesTable extends CareNotes
    with TableInfo<$CareNotesTable, CareNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _observedAtMeta =
      const VerificationMeta('observedAt');
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
      'observed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _originalTextMeta =
      const VerificationMeta('originalText');
  @override
  late final GeneratedColumn<String> originalText =
      GeneratedColumn<String>('original_text', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _structuredSummaryMeta =
      const VerificationMeta('structuredSummary');
  @override
  late final GeneratedColumn<String> structuredSummary =
      GeneratedColumn<String>('structured_summary', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _reviewStatusMeta =
      const VerificationMeta('reviewStatus');
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
      'review_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unreviewed'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        observedAt,
        recordedAt,
        originalText,
        structuredSummary,
        sourceType,
        reviewStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_notes';
  @override
  VerificationContext validateIntegrity(Insertable<CareNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
          _observedAtMeta,
          observedAt.isAcceptableOrUnknown(
              data['observed_at']!, _observedAtMeta));
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
          _originalTextMeta,
          originalText.isAcceptableOrUnknown(
              data['original_text']!, _originalTextMeta));
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('structured_summary')) {
      context.handle(
          _structuredSummaryMeta,
          structuredSummary.isAcceptableOrUnknown(
              data['structured_summary']!, _structuredSummaryMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('review_status')) {
      context.handle(
          _reviewStatusMeta,
          reviewStatus.isAcceptableOrUnknown(
              data['review_status']!, _reviewStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      observedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}observed_at'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      originalText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_text'])!,
      structuredSummary: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}structured_summary']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      reviewStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CareNotesTable createAlias(String alias) {
    return $CareNotesTable(attachedDatabase, alias);
  }
}

class CareNote extends DataClass implements Insertable<CareNote> {
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
  const CareNote(
      {required this.id,
      required this.careRecipientId,
      required this.observedAt,
      required this.recordedAt,
      required this.originalText,
      this.structuredSummary,
      required this.sourceType,
      required this.reviewStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['original_text'] = Variable<String>(originalText);
    if (!nullToAbsent || structuredSummary != null) {
      map['structured_summary'] = Variable<String>(structuredSummary);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['review_status'] = Variable<String>(reviewStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CareNotesCompanion toCompanion(bool nullToAbsent) {
    return CareNotesCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      observedAt: Value(observedAt),
      recordedAt: Value(recordedAt),
      originalText: Value(originalText),
      structuredSummary: structuredSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredSummary),
      sourceType: Value(sourceType),
      reviewStatus: Value(reviewStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CareNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareNote(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      originalText: serializer.fromJson<String>(json['originalText']),
      structuredSummary:
          serializer.fromJson<String?>(json['structuredSummary']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'originalText': serializer.toJson<String>(originalText),
      'structuredSummary': serializer.toJson<String?>(structuredSummary),
      'sourceType': serializer.toJson<String>(sourceType),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CareNote copyWith(
          {String? id,
          String? careRecipientId,
          DateTime? observedAt,
          DateTime? recordedAt,
          String? originalText,
          Value<String?> structuredSummary = const Value.absent(),
          String? sourceType,
          String? reviewStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CareNote(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        observedAt: observedAt ?? this.observedAt,
        recordedAt: recordedAt ?? this.recordedAt,
        originalText: originalText ?? this.originalText,
        structuredSummary: structuredSummary.present
            ? structuredSummary.value
            : this.structuredSummary,
        sourceType: sourceType ?? this.sourceType,
        reviewStatus: reviewStatus ?? this.reviewStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CareNote copyWithCompanion(CareNotesCompanion data) {
    return CareNote(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      observedAt:
          data.observedAt.present ? data.observedAt.value : this.observedAt,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      structuredSummary: data.structuredSummary.present
          ? data.structuredSummary.value
          : this.structuredSummary,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareNote(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('observedAt: $observedAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('originalText: $originalText, ')
          ..write('structuredSummary: $structuredSummary, ')
          ..write('sourceType: $sourceType, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      careRecipientId,
      observedAt,
      recordedAt,
      originalText,
      structuredSummary,
      sourceType,
      reviewStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareNote &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.observedAt == this.observedAt &&
          other.recordedAt == this.recordedAt &&
          other.originalText == this.originalText &&
          other.structuredSummary == this.structuredSummary &&
          other.sourceType == this.sourceType &&
          other.reviewStatus == this.reviewStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CareNotesCompanion extends UpdateCompanion<CareNote> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<DateTime> observedAt;
  final Value<DateTime> recordedAt;
  final Value<String> originalText;
  final Value<String?> structuredSummary;
  final Value<String> sourceType;
  final Value<String> reviewStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CareNotesCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.originalText = const Value.absent(),
    this.structuredSummary = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareNotesCompanion.insert({
    required String id,
    required String careRecipientId,
    required DateTime observedAt,
    required DateTime recordedAt,
    required String originalText,
    this.structuredSummary = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        observedAt = Value(observedAt),
        recordedAt = Value(recordedAt),
        originalText = Value(originalText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CareNote> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<DateTime>? observedAt,
    Expression<DateTime>? recordedAt,
    Expression<String>? originalText,
    Expression<String>? structuredSummary,
    Expression<String>? sourceType,
    Expression<String>? reviewStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (observedAt != null) 'observed_at': observedAt,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (originalText != null) 'original_text': originalText,
      if (structuredSummary != null) 'structured_summary': structuredSummary,
      if (sourceType != null) 'source_type': sourceType,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareNotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<DateTime>? observedAt,
      Value<DateTime>? recordedAt,
      Value<String>? originalText,
      Value<String?>? structuredSummary,
      Value<String>? sourceType,
      Value<String>? reviewStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CareNotesCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (structuredSummary.present) {
      map['structured_summary'] = Variable<String>(structuredSummary.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareNotesCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('observedAt: $observedAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('originalText: $originalText, ')
          ..write('structuredSummary: $structuredSummary, ')
          ..write('sourceType: $sourceType, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmergencyEventsTable extends EmergencyEvents
    with TableInfo<$EmergencyEventsTable, EmergencyEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmergencyEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _triggeredAtMeta =
      const VerificationMeta('triggeredAt');
  @override
  late final GeneratedColumn<DateTime> triggeredAt = GeneratedColumn<DateTime>(
      'triggered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _triggerTypeMeta =
      const VerificationMeta('triggerType');
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
      'trigger_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cancelledAtMeta =
      const VerificationMeta('cancelledAt');
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
      'cancelled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _selectedActionMeta =
      const VerificationMeta('selectedAction');
  @override
  late final GeneratedColumn<String> selectedAction = GeneratedColumn<String>(
      'selected_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionStatusMeta =
      const VerificationMeta('actionStatus');
  @override
  late final GeneratedColumn<String> actionStatus = GeneratedColumn<String>(
      'action_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('triggered'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        triggeredAt,
        triggerType,
        cancelledAt,
        selectedAction,
        actionStatus,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emergency_events';
  @override
  VerificationContext validateIntegrity(Insertable<EmergencyEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('triggered_at')) {
      context.handle(
          _triggeredAtMeta,
          triggeredAt.isAcceptableOrUnknown(
              data['triggered_at']!, _triggeredAtMeta));
    } else if (isInserting) {
      context.missing(_triggeredAtMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
          _triggerTypeMeta,
          triggerType.isAcceptableOrUnknown(
              data['trigger_type']!, _triggerTypeMeta));
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
          _cancelledAtMeta,
          cancelledAt.isAcceptableOrUnknown(
              data['cancelled_at']!, _cancelledAtMeta));
    }
    if (data.containsKey('selected_action')) {
      context.handle(
          _selectedActionMeta,
          selectedAction.isAcceptableOrUnknown(
              data['selected_action']!, _selectedActionMeta));
    }
    if (data.containsKey('action_status')) {
      context.handle(
          _actionStatusMeta,
          actionStatus.isAcceptableOrUnknown(
              data['action_status']!, _actionStatusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmergencyEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmergencyEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      triggeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}triggered_at'])!,
      triggerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_type'])!,
      cancelledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cancelled_at']),
      selectedAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_action']),
      actionStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EmergencyEventsTable createAlias(String alias) {
    return $EmergencyEventsTable(attachedDatabase, alias);
  }
}

class EmergencyEvent extends DataClass implements Insertable<EmergencyEvent> {
  final String id;
  final String careRecipientId;
  final DateTime triggeredAt;
  final String triggerType;
  final DateTime? cancelledAt;
  final String? selectedAction;
  final String actionStatus;
  final String? notes;
  final DateTime createdAt;
  const EmergencyEvent(
      {required this.id,
      required this.careRecipientId,
      required this.triggeredAt,
      required this.triggerType,
      this.cancelledAt,
      this.selectedAction,
      required this.actionStatus,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['triggered_at'] = Variable<DateTime>(triggeredAt);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || selectedAction != null) {
      map['selected_action'] = Variable<String>(selectedAction);
    }
    map['action_status'] = Variable<String>(actionStatus);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmergencyEventsCompanion toCompanion(bool nullToAbsent) {
    return EmergencyEventsCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      triggeredAt: Value(triggeredAt),
      triggerType: Value(triggerType),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      selectedAction: selectedAction == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedAction),
      actionStatus: Value(actionStatus),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EmergencyEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmergencyEvent(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      triggeredAt: serializer.fromJson<DateTime>(json['triggeredAt']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      selectedAction: serializer.fromJson<String?>(json['selectedAction']),
      actionStatus: serializer.fromJson<String>(json['actionStatus']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'triggeredAt': serializer.toJson<DateTime>(triggeredAt),
      'triggerType': serializer.toJson<String>(triggerType),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'selectedAction': serializer.toJson<String?>(selectedAction),
      'actionStatus': serializer.toJson<String>(actionStatus),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmergencyEvent copyWith(
          {String? id,
          String? careRecipientId,
          DateTime? triggeredAt,
          String? triggerType,
          Value<DateTime?> cancelledAt = const Value.absent(),
          Value<String?> selectedAction = const Value.absent(),
          String? actionStatus,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      EmergencyEvent(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        triggeredAt: triggeredAt ?? this.triggeredAt,
        triggerType: triggerType ?? this.triggerType,
        cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
        selectedAction:
            selectedAction.present ? selectedAction.value : this.selectedAction,
        actionStatus: actionStatus ?? this.actionStatus,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  EmergencyEvent copyWithCompanion(EmergencyEventsCompanion data) {
    return EmergencyEvent(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      triggeredAt:
          data.triggeredAt.present ? data.triggeredAt.value : this.triggeredAt,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      cancelledAt:
          data.cancelledAt.present ? data.cancelledAt.value : this.cancelledAt,
      selectedAction: data.selectedAction.present
          ? data.selectedAction.value
          : this.selectedAction,
      actionStatus: data.actionStatus.present
          ? data.actionStatus.value
          : this.actionStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyEvent(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('triggerType: $triggerType, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('selectedAction: $selectedAction, ')
          ..write('actionStatus: $actionStatus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, careRecipientId, triggeredAt, triggerType,
      cancelledAt, selectedAction, actionStatus, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyEvent &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.triggeredAt == this.triggeredAt &&
          other.triggerType == this.triggerType &&
          other.cancelledAt == this.cancelledAt &&
          other.selectedAction == this.selectedAction &&
          other.actionStatus == this.actionStatus &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EmergencyEventsCompanion extends UpdateCompanion<EmergencyEvent> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<DateTime> triggeredAt;
  final Value<String> triggerType;
  final Value<DateTime?> cancelledAt;
  final Value<String?> selectedAction;
  final Value<String> actionStatus;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EmergencyEventsCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.triggeredAt = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.selectedAction = const Value.absent(),
    this.actionStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmergencyEventsCompanion.insert({
    required String id,
    required String careRecipientId,
    required DateTime triggeredAt,
    required String triggerType,
    this.cancelledAt = const Value.absent(),
    this.selectedAction = const Value.absent(),
    this.actionStatus = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        triggeredAt = Value(triggeredAt),
        triggerType = Value(triggerType),
        createdAt = Value(createdAt);
  static Insertable<EmergencyEvent> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<DateTime>? triggeredAt,
    Expression<String>? triggerType,
    Expression<DateTime>? cancelledAt,
    Expression<String>? selectedAction,
    Expression<String>? actionStatus,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (triggeredAt != null) 'triggered_at': triggeredAt,
      if (triggerType != null) 'trigger_type': triggerType,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (selectedAction != null) 'selected_action': selectedAction,
      if (actionStatus != null) 'action_status': actionStatus,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmergencyEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<DateTime>? triggeredAt,
      Value<String>? triggerType,
      Value<DateTime?>? cancelledAt,
      Value<String?>? selectedAction,
      Value<String>? actionStatus,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return EmergencyEventsCompanion(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      triggerType: triggerType ?? this.triggerType,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      selectedAction: selectedAction ?? this.selectedAction,
      actionStatus: actionStatus ?? this.actionStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (triggeredAt.present) {
      map['triggered_at'] = Variable<DateTime>(triggeredAt.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (selectedAction.present) {
      map['selected_action'] = Variable<String>(selectedAction.value);
    }
    if (actionStatus.present) {
      map['action_status'] = Variable<String>(actionStatus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyEventsCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('triggerType: $triggerType, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('selectedAction: $selectedAction, ')
          ..write('actionStatus: $actionStatus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiCapturesTable extends AiCaptures
    with TableInfo<$AiCapturesTable, AiCapture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiCapturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _careRecipientIdMeta =
      const VerificationMeta('careRecipientId');
  @override
  late final GeneratedColumn<String> careRecipientId = GeneratedColumn<String>(
      'care_recipient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES care_recipients (id)'));
  static const VerificationMeta _modalityMeta =
      const VerificationMeta('modality');
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
      'modality', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalTextMeta =
      const VerificationMeta('originalText');
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
      'original_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _engineIdMeta =
      const VerificationMeta('engineId');
  @override
  late final GeneratedColumn<String> engineId = GeneratedColumn<String>(
      'engine_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latencyMsMeta =
      const VerificationMeta('latencyMs');
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
      'latency_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        careRecipientId,
        modality,
        originalText,
        engineId,
        modelId,
        latencyMs,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_captures';
  @override
  VerificationContext validateIntegrity(Insertable<AiCapture> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('care_recipient_id')) {
      context.handle(
          _careRecipientIdMeta,
          careRecipientId.isAcceptableOrUnknown(
              data['care_recipient_id']!, _careRecipientIdMeta));
    } else if (isInserting) {
      context.missing(_careRecipientIdMeta);
    }
    if (data.containsKey('modality')) {
      context.handle(_modalityMeta,
          modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta));
    } else if (isInserting) {
      context.missing(_modalityMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
          _originalTextMeta,
          originalText.isAcceptableOrUnknown(
              data['original_text']!, _originalTextMeta));
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('engine_id')) {
      context.handle(_engineIdMeta,
          engineId.isAcceptableOrUnknown(data['engine_id']!, _engineIdMeta));
    } else if (isInserting) {
      context.missing(_engineIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('latency_ms')) {
      context.handle(_latencyMsMeta,
          latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta));
    } else if (isInserting) {
      context.missing(_latencyMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiCapture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiCapture(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      careRecipientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}care_recipient_id'])!,
      modality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modality'])!,
      originalText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_text'])!,
      engineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}engine_id'])!,
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id'])!,
      latencyMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latency_ms'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AiCapturesTable createAlias(String alias) {
    return $AiCapturesTable(attachedDatabase, alias);
  }
}

class AiCapture extends DataClass implements Insertable<AiCapture> {
  final String id;
  final String careRecipientId;
  final String modality;
  final String originalText;
  final String engineId;
  final String modelId;
  final int latencyMs;
  final DateTime createdAt;
  const AiCapture(
      {required this.id,
      required this.careRecipientId,
      required this.modality,
      required this.originalText,
      required this.engineId,
      required this.modelId,
      required this.latencyMs,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['care_recipient_id'] = Variable<String>(careRecipientId);
    map['modality'] = Variable<String>(modality);
    map['original_text'] = Variable<String>(originalText);
    map['engine_id'] = Variable<String>(engineId);
    map['model_id'] = Variable<String>(modelId);
    map['latency_ms'] = Variable<int>(latencyMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiCapturesCompanion toCompanion(bool nullToAbsent) {
    return AiCapturesCompanion(
      id: Value(id),
      careRecipientId: Value(careRecipientId),
      modality: Value(modality),
      originalText: Value(originalText),
      engineId: Value(engineId),
      modelId: Value(modelId),
      latencyMs: Value(latencyMs),
      createdAt: Value(createdAt),
    );
  }

  factory AiCapture.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiCapture(
      id: serializer.fromJson<String>(json['id']),
      careRecipientId: serializer.fromJson<String>(json['careRecipientId']),
      modality: serializer.fromJson<String>(json['modality']),
      originalText: serializer.fromJson<String>(json['originalText']),
      engineId: serializer.fromJson<String>(json['engineId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      latencyMs: serializer.fromJson<int>(json['latencyMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'careRecipientId': serializer.toJson<String>(careRecipientId),
      'modality': serializer.toJson<String>(modality),
      'originalText': serializer.toJson<String>(originalText),
      'engineId': serializer.toJson<String>(engineId),
      'modelId': serializer.toJson<String>(modelId),
      'latencyMs': serializer.toJson<int>(latencyMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiCapture copyWith(
          {String? id,
          String? careRecipientId,
          String? modality,
          String? originalText,
          String? engineId,
          String? modelId,
          int? latencyMs,
          DateTime? createdAt}) =>
      AiCapture(
        id: id ?? this.id,
        careRecipientId: careRecipientId ?? this.careRecipientId,
        modality: modality ?? this.modality,
        originalText: originalText ?? this.originalText,
        engineId: engineId ?? this.engineId,
        modelId: modelId ?? this.modelId,
        latencyMs: latencyMs ?? this.latencyMs,
        createdAt: createdAt ?? this.createdAt,
      );
  AiCapture copyWithCompanion(AiCapturesCompanion data) {
    return AiCapture(
      id: data.id.present ? data.id.value : this.id,
      careRecipientId: data.careRecipientId.present
          ? data.careRecipientId.value
          : this.careRecipientId,
      modality: data.modality.present ? data.modality.value : this.modality,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      engineId: data.engineId.present ? data.engineId.value : this.engineId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiCapture(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('modality: $modality, ')
          ..write('originalText: $originalText, ')
          ..write('engineId: $engineId, ')
          ..write('modelId: $modelId, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, careRecipientId, modality, originalText,
      engineId, modelId, latencyMs, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiCapture &&
          other.id == this.id &&
          other.careRecipientId == this.careRecipientId &&
          other.modality == this.modality &&
          other.originalText == this.originalText &&
          other.engineId == this.engineId &&
          other.modelId == this.modelId &&
          other.latencyMs == this.latencyMs &&
          other.createdAt == this.createdAt);
}

class AiCapturesCompanion extends UpdateCompanion<AiCapture> {
  final Value<String> id;
  final Value<String> careRecipientId;
  final Value<String> modality;
  final Value<String> originalText;
  final Value<String> engineId;
  final Value<String> modelId;
  final Value<int> latencyMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiCapturesCompanion({
    this.id = const Value.absent(),
    this.careRecipientId = const Value.absent(),
    this.modality = const Value.absent(),
    this.originalText = const Value.absent(),
    this.engineId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiCapturesCompanion.insert({
    required String id,
    required String careRecipientId,
    required String modality,
    required String originalText,
    required String engineId,
    required String modelId,
    required int latencyMs,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        careRecipientId = Value(careRecipientId),
        modality = Value(modality),
        originalText = Value(originalText),
        engineId = Value(engineId),
        modelId = Value(modelId),
        latencyMs = Value(latencyMs),
        createdAt = Value(createdAt);
  static Insertable<AiCapture> custom({
    Expression<String>? id,
    Expression<String>? careRecipientId,
    Expression<String>? modality,
    Expression<String>? originalText,
    Expression<String>? engineId,
    Expression<String>? modelId,
    Expression<int>? latencyMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (careRecipientId != null) 'care_recipient_id': careRecipientId,
      if (modality != null) 'modality': modality,
      if (originalText != null) 'original_text': originalText,
      if (engineId != null) 'engine_id': engineId,
      if (modelId != null) 'model_id': modelId,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiCapturesCompanion copyWith(
      {Value<String>? id,
      Value<String>? careRecipientId,
      Value<String>? modality,
      Value<String>? originalText,
      Value<String>? engineId,
      Value<String>? modelId,
      Value<int>? latencyMs,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AiCapturesCompanion(
      id: id ?? this.id,
      careRecipientId: careRecipientId ?? this.careRecipientId,
      modality: modality ?? this.modality,
      originalText: originalText ?? this.originalText,
      engineId: engineId ?? this.engineId,
      modelId: modelId ?? this.modelId,
      latencyMs: latencyMs ?? this.latencyMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (careRecipientId.present) {
      map['care_recipient_id'] = Variable<String>(careRecipientId.value);
    }
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (engineId.present) {
      map['engine_id'] = Variable<String>(engineId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiCapturesCompanion(')
          ..write('id: $id, ')
          ..write('careRecipientId: $careRecipientId, ')
          ..write('modality: $modality, ')
          ..write('originalText: $originalText, ')
          ..write('engineId: $engineId, ')
          ..write('modelId: $modelId, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiProposalsTable extends AiProposals
    with TableInfo<$AiProposalsTable, AiProposal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captureIdMeta =
      const VerificationMeta('captureId');
  @override
  late final GeneratedColumn<String> captureId = GeneratedColumn<String>(
      'capture_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ai_captures (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceQuoteMeta =
      const VerificationMeta('sourceQuote');
  @override
  late final GeneratedColumn<String> sourceQuote = GeneratedColumn<String>(
      'source_quote', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<String> flag = GeneratedColumn<String>(
      'flag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, captureId, kind, payloadJson, sourceQuote, flag, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_proposals';
  @override
  VerificationContext validateIntegrity(Insertable<AiProposal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capture_id')) {
      context.handle(_captureIdMeta,
          captureId.isAcceptableOrUnknown(data['capture_id']!, _captureIdMeta));
    } else if (isInserting) {
      context.missing(_captureIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('source_quote')) {
      context.handle(
          _sourceQuoteMeta,
          sourceQuote.isAcceptableOrUnknown(
              data['source_quote']!, _sourceQuoteMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiProposal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProposal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      captureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capture_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      sourceQuote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_quote']),
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flag']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AiProposalsTable createAlias(String alias) {
    return $AiProposalsTable(attachedDatabase, alias);
  }
}

class AiProposal extends DataClass implements Insertable<AiProposal> {
  final String id;
  final String captureId;
  final String kind;
  final String payloadJson;
  final String? sourceQuote;
  final String? flag;
  final String status;
  final DateTime createdAt;
  const AiProposal(
      {required this.id,
      required this.captureId,
      required this.kind,
      required this.payloadJson,
      this.sourceQuote,
      this.flag,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['capture_id'] = Variable<String>(captureId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || sourceQuote != null) {
      map['source_quote'] = Variable<String>(sourceQuote);
    }
    if (!nullToAbsent || flag != null) {
      map['flag'] = Variable<String>(flag);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiProposalsCompanion toCompanion(bool nullToAbsent) {
    return AiProposalsCompanion(
      id: Value(id),
      captureId: Value(captureId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      sourceQuote: sourceQuote == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceQuote),
      flag: flag == null && nullToAbsent ? const Value.absent() : Value(flag),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory AiProposal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProposal(
      id: serializer.fromJson<String>(json['id']),
      captureId: serializer.fromJson<String>(json['captureId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      sourceQuote: serializer.fromJson<String?>(json['sourceQuote']),
      flag: serializer.fromJson<String?>(json['flag']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'captureId': serializer.toJson<String>(captureId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'sourceQuote': serializer.toJson<String?>(sourceQuote),
      'flag': serializer.toJson<String?>(flag),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiProposal copyWith(
          {String? id,
          String? captureId,
          String? kind,
          String? payloadJson,
          Value<String?> sourceQuote = const Value.absent(),
          Value<String?> flag = const Value.absent(),
          String? status,
          DateTime? createdAt}) =>
      AiProposal(
        id: id ?? this.id,
        captureId: captureId ?? this.captureId,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        sourceQuote: sourceQuote.present ? sourceQuote.value : this.sourceQuote,
        flag: flag.present ? flag.value : this.flag,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  AiProposal copyWithCompanion(AiProposalsCompanion data) {
    return AiProposal(
      id: data.id.present ? data.id.value : this.id,
      captureId: data.captureId.present ? data.captureId.value : this.captureId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      sourceQuote:
          data.sourceQuote.present ? data.sourceQuote.value : this.sourceQuote,
      flag: data.flag.present ? data.flag.value : this.flag,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiProposal(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sourceQuote: $sourceQuote, ')
          ..write('flag: $flag, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, captureId, kind, payloadJson, sourceQuote, flag, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiProposal &&
          other.id == this.id &&
          other.captureId == this.captureId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.sourceQuote == this.sourceQuote &&
          other.flag == this.flag &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class AiProposalsCompanion extends UpdateCompanion<AiProposal> {
  final Value<String> id;
  final Value<String> captureId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<String?> sourceQuote;
  final Value<String?> flag;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiProposalsCompanion({
    this.id = const Value.absent(),
    this.captureId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.sourceQuote = const Value.absent(),
    this.flag = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiProposalsCompanion.insert({
    required String id,
    required String captureId,
    required String kind,
    required String payloadJson,
    this.sourceQuote = const Value.absent(),
    this.flag = const Value.absent(),
    required String status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        captureId = Value(captureId),
        kind = Value(kind),
        payloadJson = Value(payloadJson),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<AiProposal> custom({
    Expression<String>? id,
    Expression<String>? captureId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<String>? sourceQuote,
    Expression<String>? flag,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (captureId != null) 'capture_id': captureId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (sourceQuote != null) 'source_quote': sourceQuote,
      if (flag != null) 'flag': flag,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiProposalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? captureId,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<String?>? sourceQuote,
      Value<String?>? flag,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AiProposalsCompanion(
      id: id ?? this.id,
      captureId: captureId ?? this.captureId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      sourceQuote: sourceQuote ?? this.sourceQuote,
      flag: flag ?? this.flag,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (captureId.present) {
      map['capture_id'] = Variable<String>(captureId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (sourceQuote.present) {
      map['source_quote'] = Variable<String>(sourceQuote.value);
    }
    if (flag.present) {
      map['flag'] = Variable<String>(flag.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiProposalsCompanion(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sourceQuote: $sourceQuote, ')
          ..write('flag: $flag, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CareRecipientsTable careRecipients = $CareRecipientsTable(this);
  late final $FamilyContactsTable familyContacts = $FamilyContactsTable(this);
  late final $MedicationSchedulesTable medicationSchedules =
      $MedicationSchedulesTable(this);
  late final $MedicationOccurrencesTable medicationOccurrences =
      $MedicationOccurrencesTable(this);
  late final $MeasurementLogsTable measurementLogs =
      $MeasurementLogsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $CareNotesTable careNotes = $CareNotesTable(this);
  late final $EmergencyEventsTable emergencyEvents =
      $EmergencyEventsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AiCapturesTable aiCaptures = $AiCapturesTable(this);
  late final $AiProposalsTable aiProposals = $AiProposalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        careRecipients,
        familyContacts,
        medicationSchedules,
        medicationOccurrences,
        measurementLogs,
        appointments,
        careNotes,
        emergencyEvents,
        appSettings,
        aiCaptures,
        aiProposals
      ];
}

typedef $$CareRecipientsTableCreateCompanionBuilder = CareRecipientsCompanion
    Function({
  required String id,
  required String displayName,
  Value<DateTime?> dateOfBirth,
  Value<String?> allergies,
  Value<String?> importantNotes,
  Value<String?> emergencyInfo,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CareRecipientsTableUpdateCompanionBuilder = CareRecipientsCompanion
    Function({
  Value<String> id,
  Value<String> displayName,
  Value<DateTime?> dateOfBirth,
  Value<String?> allergies,
  Value<String?> importantNotes,
  Value<String?> emergencyInfo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CareRecipientsTableReferences
    extends BaseReferences<_$AppDatabase, $CareRecipientsTable, CareRecipient> {
  $$CareRecipientsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FamilyContactsTable, List<FamilyContact>>
      _familyContactsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.familyContacts,
              aliasName:
                  'care_recipients__id__family_contacts__care_recipient_id');

  $$FamilyContactsTableProcessedTableManager get familyContactsRefs {
    final manager = $$FamilyContactsTableTableManager($_db, $_db.familyContacts)
        .filter(
            (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_familyContactsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MedicationSchedulesTable,
      List<MedicationSchedule>> _medicationSchedulesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.medicationSchedules,
          aliasName:
              'care_recipients__id__medication_schedules__care_recipient_id');

  $$MedicationSchedulesTableProcessedTableManager get medicationSchedulesRefs {
    final manager = $$MedicationSchedulesTableTableManager(
            $_db, $_db.medicationSchedules)
        .filter(
            (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_medicationSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MeasurementLogsTable, List<MeasurementLog>>
      _measurementLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurementLogs,
              aliasName:
                  'care_recipients__id__measurement_logs__care_recipient_id');

  $$MeasurementLogsTableProcessedTableManager get measurementLogsRefs {
    final manager =
        $$MeasurementLogsTableTableManager($_db, $_db.measurementLogs).filter(
            (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_measurementLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
      _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.appointments,
          aliasName: 'care_recipients__id__appointments__care_recipient_id');

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager($_db, $_db.appointments)
        .filter(
            (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CareNotesTable, List<CareNote>>
      _careNotesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.careNotes,
              aliasName: 'care_recipients__id__care_notes__care_recipient_id');

  $$CareNotesTableProcessedTableManager get careNotesRefs {
    final manager = $$CareNotesTableTableManager($_db, $_db.careNotes).filter(
        (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_careNotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EmergencyEventsTable, List<EmergencyEvent>>
      _emergencyEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.emergencyEvents,
              aliasName:
                  'care_recipients__id__emergency_events__care_recipient_id');

  $$EmergencyEventsTableProcessedTableManager get emergencyEventsRefs {
    final manager =
        $$EmergencyEventsTableTableManager($_db, $_db.emergencyEvents).filter(
            (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_emergencyEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AiCapturesTable, List<AiCapture>>
      _aiCapturesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aiCaptures,
              aliasName: 'care_recipients__id__ai_captures__care_recipient_id');

  $$AiCapturesTableProcessedTableManager get aiCapturesRefs {
    final manager = $$AiCapturesTableTableManager($_db, $_db.aiCaptures).filter(
        (f) => f.careRecipientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_aiCapturesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CareRecipientsTableFilterComposer
    extends Composer<_$AppDatabase, $CareRecipientsTable> {
  $$CareRecipientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get importantNotes => $composableBuilder(
      column: $table.importantNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emergencyInfo => $composableBuilder(
      column: $table.emergencyInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> familyContactsRefs(
      Expression<bool> Function($$FamilyContactsTableFilterComposer f) f) {
    final $$FamilyContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.familyContacts,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FamilyContactsTableFilterComposer(
              $db: $db,
              $table: $db.familyContacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> medicationSchedulesRefs(
      Expression<bool> Function($$MedicationSchedulesTableFilterComposer f) f) {
    final $$MedicationSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medicationSchedules,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.medicationSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> measurementLogsRefs(
      Expression<bool> Function($$MeasurementLogsTableFilterComposer f) f) {
    final $$MeasurementLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementLogs,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementLogsTableFilterComposer(
              $db: $db,
              $table: $db.measurementLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> appointmentsRefs(
      Expression<bool> Function($$AppointmentsTableFilterComposer f) f) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableFilterComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> careNotesRefs(
      Expression<bool> Function($$CareNotesTableFilterComposer f) f) {
    final $$CareNotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.careNotes,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareNotesTableFilterComposer(
              $db: $db,
              $table: $db.careNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> emergencyEventsRefs(
      Expression<bool> Function($$EmergencyEventsTableFilterComposer f) f) {
    final $$EmergencyEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emergencyEvents,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmergencyEventsTableFilterComposer(
              $db: $db,
              $table: $db.emergencyEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> aiCapturesRefs(
      Expression<bool> Function($$AiCapturesTableFilterComposer f) f) {
    final $$AiCapturesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiCaptures,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiCapturesTableFilterComposer(
              $db: $db,
              $table: $db.aiCaptures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CareRecipientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CareRecipientsTable> {
  $$CareRecipientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get importantNotes => $composableBuilder(
      column: $table.importantNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emergencyInfo => $composableBuilder(
      column: $table.emergencyInfo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CareRecipientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareRecipientsTable> {
  $$CareRecipientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get importantNotes => $composableBuilder(
      column: $table.importantNotes, builder: (column) => column);

  GeneratedColumn<String> get emergencyInfo => $composableBuilder(
      column: $table.emergencyInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> familyContactsRefs<T extends Object>(
      Expression<T> Function($$FamilyContactsTableAnnotationComposer a) f) {
    final $$FamilyContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.familyContacts,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FamilyContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.familyContacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> medicationSchedulesRefs<T extends Object>(
      Expression<T> Function($$MedicationSchedulesTableAnnotationComposer a)
          f) {
    final $$MedicationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.medicationSchedules,
            getReferencedColumn: (t) => t.careRecipientId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationSchedulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.medicationSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> measurementLogsRefs<T extends Object>(
      Expression<T> Function($$MeasurementLogsTableAnnotationComposer a) f) {
    final $$MeasurementLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementLogs,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurementLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> appointmentsRefs<T extends Object>(
      Expression<T> Function($$AppointmentsTableAnnotationComposer a) f) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> careNotesRefs<T extends Object>(
      Expression<T> Function($$CareNotesTableAnnotationComposer a) f) {
    final $$CareNotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.careNotes,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.careNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> emergencyEventsRefs<T extends Object>(
      Expression<T> Function($$EmergencyEventsTableAnnotationComposer a) f) {
    final $$EmergencyEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emergencyEvents,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmergencyEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.emergencyEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> aiCapturesRefs<T extends Object>(
      Expression<T> Function($$AiCapturesTableAnnotationComposer a) f) {
    final $$AiCapturesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiCaptures,
        getReferencedColumn: (t) => t.careRecipientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiCapturesTableAnnotationComposer(
              $db: $db,
              $table: $db.aiCaptures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CareRecipientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CareRecipientsTable,
    CareRecipient,
    $$CareRecipientsTableFilterComposer,
    $$CareRecipientsTableOrderingComposer,
    $$CareRecipientsTableAnnotationComposer,
    $$CareRecipientsTableCreateCompanionBuilder,
    $$CareRecipientsTableUpdateCompanionBuilder,
    (CareRecipient, $$CareRecipientsTableReferences),
    CareRecipient,
    PrefetchHooks Function(
        {bool familyContactsRefs,
        bool medicationSchedulesRefs,
        bool measurementLogsRefs,
        bool appointmentsRefs,
        bool careNotesRefs,
        bool emergencyEventsRefs,
        bool aiCapturesRefs})> {
  $$CareRecipientsTableTableManager(
      _$AppDatabase db, $CareRecipientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareRecipientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareRecipientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareRecipientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            Value<String?> importantNotes = const Value.absent(),
            Value<String?> emergencyInfo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CareRecipientsCompanion(
            id: id,
            displayName: displayName,
            dateOfBirth: dateOfBirth,
            allergies: allergies,
            importantNotes: importantNotes,
            emergencyInfo: emergencyInfo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            Value<String?> importantNotes = const Value.absent(),
            Value<String?> emergencyInfo = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CareRecipientsCompanion.insert(
            id: id,
            displayName: displayName,
            dateOfBirth: dateOfBirth,
            allergies: allergies,
            importantNotes: importantNotes,
            emergencyInfo: emergencyInfo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CareRecipientsTable, CareRecipient>(table),
                    $$CareRecipientsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {familyContactsRefs = false,
              medicationSchedulesRefs = false,
              measurementLogsRefs = false,
              appointmentsRefs = false,
              careNotesRefs = false,
              emergencyEventsRefs = false,
              aiCapturesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (familyContactsRefs) db.familyContacts,
                if (medicationSchedulesRefs) db.medicationSchedules,
                if (measurementLogsRefs) db.measurementLogs,
                if (appointmentsRefs) db.appointments,
                if (careNotesRefs) db.careNotes,
                if (emergencyEventsRefs) db.emergencyEvents,
                if (aiCapturesRefs) db.aiCaptures
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (familyContactsRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, FamilyContact>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._familyContactsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .familyContactsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (medicationSchedulesRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, MedicationSchedule>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._medicationSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .medicationSchedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (measurementLogsRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, MeasurementLog>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._measurementLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .measurementLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (appointmentsRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, Appointment>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._appointmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .appointmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (careNotesRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, CareNote>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._careNotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .careNotesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (emergencyEventsRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, EmergencyEvent>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._emergencyEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .emergencyEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items),
                  if (aiCapturesRefs)
                    await $_getPrefetchedData<CareRecipient,
                            $CareRecipientsTable, AiCapture>(
                        currentTable: table,
                        referencedTable: $$CareRecipientsTableReferences
                            ._aiCapturesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CareRecipientsTableReferences(db, table, p0)
                                .aiCapturesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.careRecipientId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CareRecipientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CareRecipientsTable,
    CareRecipient,
    $$CareRecipientsTableFilterComposer,
    $$CareRecipientsTableOrderingComposer,
    $$CareRecipientsTableAnnotationComposer,
    $$CareRecipientsTableCreateCompanionBuilder,
    $$CareRecipientsTableUpdateCompanionBuilder,
    (CareRecipient, $$CareRecipientsTableReferences),
    CareRecipient,
    PrefetchHooks Function(
        {bool familyContactsRefs,
        bool medicationSchedulesRefs,
        bool measurementLogsRefs,
        bool appointmentsRefs,
        bool careNotesRefs,
        bool emergencyEventsRefs,
        bool aiCapturesRefs})>;
typedef $$FamilyContactsTableCreateCompanionBuilder = FamilyContactsCompanion
    Function({
  required String id,
  required String careRecipientId,
  required String displayName,
  Value<String?> relationship,
  required String phoneNumber,
  Value<bool> isEmergencyContact,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FamilyContactsTableUpdateCompanionBuilder = FamilyContactsCompanion
    Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<String> displayName,
  Value<String?> relationship,
  Value<String> phoneNumber,
  Value<bool> isEmergencyContact,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FamilyContactsTableReferences
    extends BaseReferences<_$AppDatabase, $FamilyContactsTable, FamilyContact> {
  $$FamilyContactsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) => db
      .careRecipients
      .createAlias('family_contacts__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FamilyContactsTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyContactsTable> {
  $$FamilyContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEmergencyContact => $composableBuilder(
      column: $table.isEmergencyContact,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FamilyContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyContactsTable> {
  $$FamilyContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationship => $composableBuilder(
      column: $table.relationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEmergencyContact => $composableBuilder(
      column: $table.isEmergencyContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FamilyContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyContactsTable> {
  $$FamilyContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<bool> get isEmergencyContact => $composableBuilder(
      column: $table.isEmergencyContact, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FamilyContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamilyContactsTable,
    FamilyContact,
    $$FamilyContactsTableFilterComposer,
    $$FamilyContactsTableOrderingComposer,
    $$FamilyContactsTableAnnotationComposer,
    $$FamilyContactsTableCreateCompanionBuilder,
    $$FamilyContactsTableUpdateCompanionBuilder,
    (FamilyContact, $$FamilyContactsTableReferences),
    FamilyContact,
    PrefetchHooks Function({bool careRecipientId})> {
  $$FamilyContactsTableTableManager(
      _$AppDatabase db, $FamilyContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> relationship = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<bool> isEmergencyContact = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FamilyContactsCompanion(
            id: id,
            careRecipientId: careRecipientId,
            displayName: displayName,
            relationship: relationship,
            phoneNumber: phoneNumber,
            isEmergencyContact: isEmergencyContact,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required String displayName,
            Value<String?> relationship = const Value.absent(),
            required String phoneNumber,
            Value<bool> isEmergencyContact = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FamilyContactsCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            displayName: displayName,
            relationship: relationship,
            phoneNumber: phoneNumber,
            isEmergencyContact: isEmergencyContact,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FamilyContactsTable, FamilyContact>(table),
                    $$FamilyContactsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({careRecipientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable: $$FamilyContactsTableReferences
                        ._careRecipientIdTable(db),
                    referencedColumn: $$FamilyContactsTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FamilyContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamilyContactsTable,
    FamilyContact,
    $$FamilyContactsTableFilterComposer,
    $$FamilyContactsTableOrderingComposer,
    $$FamilyContactsTableAnnotationComposer,
    $$FamilyContactsTableCreateCompanionBuilder,
    $$FamilyContactsTableUpdateCompanionBuilder,
    (FamilyContact, $$FamilyContactsTableReferences),
    FamilyContact,
    PrefetchHooks Function({bool careRecipientId})>;
typedef $$MedicationSchedulesTableCreateCompanionBuilder
    = MedicationSchedulesCompanion Function({
  required String id,
  required String careRecipientId,
  required String medicationName,
  Value<String?> prescribedInstructions,
  required String scheduleTimes,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<String?> notes,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MedicationSchedulesTableUpdateCompanionBuilder
    = MedicationSchedulesCompanion Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<String> medicationName,
  Value<String?> prescribedInstructions,
  Value<String> scheduleTimes,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MedicationSchedulesTableReferences extends BaseReferences<
    _$AppDatabase, $MedicationSchedulesTable, MedicationSchedule> {
  $$MedicationSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) =>
      db.careRecipients.createAlias(
          'medication_schedules__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MedicationOccurrencesTable,
      List<MedicationOccurrence>> _medicationOccurrencesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.medicationOccurrences,
          aliasName:
              'medication_schedules__id__medication_occurrences__medication_schedule_id');

  $$MedicationOccurrencesTableProcessedTableManager
      get medicationOccurrencesRefs {
    final manager = $$MedicationOccurrencesTableTableManager(
            $_db, $_db.medicationOccurrences)
        .filter((f) =>
            f.medicationScheduleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_medicationOccurrencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prescribedInstructions => $composableBuilder(
      column: $table.prescribedInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleTimes => $composableBuilder(
      column: $table.scheduleTimes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> medicationOccurrencesRefs(
      Expression<bool> Function($$MedicationOccurrencesTableFilterComposer f)
          f) {
    final $$MedicationOccurrencesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.medicationOccurrences,
            getReferencedColumn: (t) => t.medicationScheduleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationOccurrencesTableFilterComposer(
                  $db: $db,
                  $table: $db.medicationOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MedicationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prescribedInstructions => $composableBuilder(
      column: $table.prescribedInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleTimes => $composableBuilder(
      column: $table.scheduleTimes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
      column: $table.medicationName, builder: (column) => column);

  GeneratedColumn<String> get prescribedInstructions => $composableBuilder(
      column: $table.prescribedInstructions, builder: (column) => column);

  GeneratedColumn<String> get scheduleTimes => $composableBuilder(
      column: $table.scheduleTimes, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> medicationOccurrencesRefs<T extends Object>(
      Expression<T> Function($$MedicationOccurrencesTableAnnotationComposer a)
          f) {
    final $$MedicationOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.medicationOccurrences,
            getReferencedColumn: (t) => t.medicationScheduleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationOccurrencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.medicationOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MedicationSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationSchedulesTable,
    MedicationSchedule,
    $$MedicationSchedulesTableFilterComposer,
    $$MedicationSchedulesTableOrderingComposer,
    $$MedicationSchedulesTableAnnotationComposer,
    $$MedicationSchedulesTableCreateCompanionBuilder,
    $$MedicationSchedulesTableUpdateCompanionBuilder,
    (MedicationSchedule, $$MedicationSchedulesTableReferences),
    MedicationSchedule,
    PrefetchHooks Function(
        {bool careRecipientId, bool medicationOccurrencesRefs})> {
  $$MedicationSchedulesTableTableManager(
      _$AppDatabase db, $MedicationSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationSchedulesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationSchedulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<String> medicationName = const Value.absent(),
            Value<String?> prescribedInstructions = const Value.absent(),
            Value<String> scheduleTimes = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationSchedulesCompanion(
            id: id,
            careRecipientId: careRecipientId,
            medicationName: medicationName,
            prescribedInstructions: prescribedInstructions,
            scheduleTimes: scheduleTimes,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required String medicationName,
            Value<String?> prescribedInstructions = const Value.absent(),
            required String scheduleTimes,
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationSchedulesCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            medicationName: medicationName,
            prescribedInstructions: prescribedInstructions,
            scheduleTimes: scheduleTimes,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicationSchedulesTable, MedicationSchedule>(
                        table),
                    $$MedicationSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {careRecipientId = false, medicationOccurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationOccurrencesRefs) db.medicationOccurrences
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable: $$MedicationSchedulesTableReferences
                        ._careRecipientIdTable(db),
                    referencedColumn: $$MedicationSchedulesTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationOccurrencesRefs)
                    await $_getPrefetchedData<MedicationSchedule,
                            $MedicationSchedulesTable, MedicationOccurrence>(
                        currentTable: table,
                        referencedTable: $$MedicationSchedulesTableReferences
                            ._medicationOccurrencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicationSchedulesTableReferences(db, table, p0)
                                .medicationOccurrencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationScheduleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MedicationSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationSchedulesTable,
    MedicationSchedule,
    $$MedicationSchedulesTableFilterComposer,
    $$MedicationSchedulesTableOrderingComposer,
    $$MedicationSchedulesTableAnnotationComposer,
    $$MedicationSchedulesTableCreateCompanionBuilder,
    $$MedicationSchedulesTableUpdateCompanionBuilder,
    (MedicationSchedule, $$MedicationSchedulesTableReferences),
    MedicationSchedule,
    PrefetchHooks Function(
        {bool careRecipientId, bool medicationOccurrencesRefs})>;
typedef $$MedicationOccurrencesTableCreateCompanionBuilder
    = MedicationOccurrencesCompanion Function({
  required String id,
  required String medicationScheduleId,
  required DateTime scheduledAt,
  Value<String> status,
  Value<DateTime?> statusUpdatedAt,
  Value<String> statusSource,
  Value<String?> statusNote,
  Value<String?> recordedByLabel,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicationOccurrencesTableUpdateCompanionBuilder
    = MedicationOccurrencesCompanion Function({
  Value<String> id,
  Value<String> medicationScheduleId,
  Value<DateTime> scheduledAt,
  Value<String> status,
  Value<DateTime?> statusUpdatedAt,
  Value<String> statusSource,
  Value<String?> statusNote,
  Value<String?> recordedByLabel,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MedicationOccurrencesTableReferences extends BaseReferences<
    _$AppDatabase, $MedicationOccurrencesTable, MedicationOccurrence> {
  $$MedicationOccurrencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MedicationSchedulesTable _medicationScheduleIdTable(
          _$AppDatabase db) =>
      db.medicationSchedules.createAlias(
          'medication_occurrences__medication_schedule_id__medication_schedules__id');

  $$MedicationSchedulesTableProcessedTableManager get medicationScheduleId {
    final $_column = $_itemColumn<String>('medication_schedule_id')!;

    final manager =
        $$MedicationSchedulesTableTableManager($_db, $_db.medicationSchedules)
            .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_medicationScheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MedicationOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationOccurrencesTable> {
  $$MedicationOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get statusUpdatedAt => $composableBuilder(
      column: $table.statusUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusSource => $composableBuilder(
      column: $table.statusSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusNote => $composableBuilder(
      column: $table.statusNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordedByLabel => $composableBuilder(
      column: $table.recordedByLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MedicationSchedulesTableFilterComposer get medicationScheduleId {
    final $$MedicationSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicationScheduleId,
        referencedTable: $db.medicationSchedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.medicationSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationOccurrencesTable> {
  $$MedicationOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get statusUpdatedAt => $composableBuilder(
      column: $table.statusUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusSource => $composableBuilder(
      column: $table.statusSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusNote => $composableBuilder(
      column: $table.statusNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordedByLabel => $composableBuilder(
      column: $table.recordedByLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MedicationSchedulesTableOrderingComposer get medicationScheduleId {
    final $$MedicationSchedulesTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.medicationScheduleId,
            referencedTable: $db.medicationSchedules,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationSchedulesTableOrderingComposer(
                  $db: $db,
                  $table: $db.medicationSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$MedicationOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationOccurrencesTable> {
  $$MedicationOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get statusUpdatedAt => $composableBuilder(
      column: $table.statusUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get statusSource => $composableBuilder(
      column: $table.statusSource, builder: (column) => column);

  GeneratedColumn<String> get statusNote => $composableBuilder(
      column: $table.statusNote, builder: (column) => column);

  GeneratedColumn<String> get recordedByLabel => $composableBuilder(
      column: $table.recordedByLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicationSchedulesTableAnnotationComposer get medicationScheduleId {
    final $$MedicationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.medicationScheduleId,
            referencedTable: $db.medicationSchedules,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationSchedulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.medicationSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$MedicationOccurrencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationOccurrencesTable,
    MedicationOccurrence,
    $$MedicationOccurrencesTableFilterComposer,
    $$MedicationOccurrencesTableOrderingComposer,
    $$MedicationOccurrencesTableAnnotationComposer,
    $$MedicationOccurrencesTableCreateCompanionBuilder,
    $$MedicationOccurrencesTableUpdateCompanionBuilder,
    (MedicationOccurrence, $$MedicationOccurrencesTableReferences),
    MedicationOccurrence,
    PrefetchHooks Function({bool medicationScheduleId})> {
  $$MedicationOccurrencesTableTableManager(
      _$AppDatabase db, $MedicationOccurrencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationOccurrencesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationOccurrencesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationOccurrencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> medicationScheduleId = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> statusUpdatedAt = const Value.absent(),
            Value<String> statusSource = const Value.absent(),
            Value<String?> statusNote = const Value.absent(),
            Value<String?> recordedByLabel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationOccurrencesCompanion(
            id: id,
            medicationScheduleId: medicationScheduleId,
            scheduledAt: scheduledAt,
            status: status,
            statusUpdatedAt: statusUpdatedAt,
            statusSource: statusSource,
            statusNote: statusNote,
            recordedByLabel: recordedByLabel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String medicationScheduleId,
            required DateTime scheduledAt,
            Value<String> status = const Value.absent(),
            Value<DateTime?> statusUpdatedAt = const Value.absent(),
            Value<String> statusSource = const Value.absent(),
            Value<String?> statusNote = const Value.absent(),
            Value<String?> recordedByLabel = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationOccurrencesCompanion.insert(
            id: id,
            medicationScheduleId: medicationScheduleId,
            scheduledAt: scheduledAt,
            status: status,
            statusUpdatedAt: statusUpdatedAt,
            statusSource: statusSource,
            statusNote: statusNote,
            recordedByLabel: recordedByLabel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicationOccurrencesTable,
                        MedicationOccurrence>(table),
                    $$MedicationOccurrencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({medicationScheduleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (medicationScheduleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.medicationScheduleId,
                    referencedTable: $$MedicationOccurrencesTableReferences
                        ._medicationScheduleIdTable(db),
                    referencedColumn: $$MedicationOccurrencesTableReferences
                        ._medicationScheduleIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MedicationOccurrencesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MedicationOccurrencesTable,
        MedicationOccurrence,
        $$MedicationOccurrencesTableFilterComposer,
        $$MedicationOccurrencesTableOrderingComposer,
        $$MedicationOccurrencesTableAnnotationComposer,
        $$MedicationOccurrencesTableCreateCompanionBuilder,
        $$MedicationOccurrencesTableUpdateCompanionBuilder,
        (MedicationOccurrence, $$MedicationOccurrencesTableReferences),
        MedicationOccurrence,
        PrefetchHooks Function({bool medicationScheduleId})>;
typedef $$MeasurementLogsTableCreateCompanionBuilder = MeasurementLogsCompanion
    Function({
  required String id,
  required String careRecipientId,
  required String measurementType,
  required double value1,
  Value<double?> value2,
  required String unit,
  required DateTime measuredAt,
  required DateTime recordedAt,
  Value<String> sourceType,
  Value<String?> sourceLabel,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MeasurementLogsTableUpdateCompanionBuilder = MeasurementLogsCompanion
    Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<String> measurementType,
  Value<double> value1,
  Value<double?> value2,
  Value<String> unit,
  Value<DateTime> measuredAt,
  Value<DateTime> recordedAt,
  Value<String> sourceType,
  Value<String?> sourceLabel,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MeasurementLogsTableReferences extends BaseReferences<
    _$AppDatabase, $MeasurementLogsTable, MeasurementLog> {
  $$MeasurementLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) => db
      .careRecipients
      .createAlias('measurement_logs__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MeasurementLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementLogsTable> {
  $$MeasurementLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get measurementType => $composableBuilder(
      column: $table.measurementType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value1 => $composableBuilder(
      column: $table.value1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value2 => $composableBuilder(
      column: $table.value2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceLabel => $composableBuilder(
      column: $table.sourceLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementLogsTable> {
  $$MeasurementLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get measurementType => $composableBuilder(
      column: $table.measurementType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value1 => $composableBuilder(
      column: $table.value1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value2 => $composableBuilder(
      column: $table.value2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceLabel => $composableBuilder(
      column: $table.sourceLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementLogsTable> {
  $$MeasurementLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get measurementType => $composableBuilder(
      column: $table.measurementType, builder: (column) => column);

  GeneratedColumn<double> get value1 =>
      $composableBuilder(column: $table.value1, builder: (column) => column);

  GeneratedColumn<double> get value2 =>
      $composableBuilder(column: $table.value2, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceLabel => $composableBuilder(
      column: $table.sourceLabel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementLogsTable,
    MeasurementLog,
    $$MeasurementLogsTableFilterComposer,
    $$MeasurementLogsTableOrderingComposer,
    $$MeasurementLogsTableAnnotationComposer,
    $$MeasurementLogsTableCreateCompanionBuilder,
    $$MeasurementLogsTableUpdateCompanionBuilder,
    (MeasurementLog, $$MeasurementLogsTableReferences),
    MeasurementLog,
    PrefetchHooks Function({bool careRecipientId})> {
  $$MeasurementLogsTableTableManager(
      _$AppDatabase db, $MeasurementLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<String> measurementType = const Value.absent(),
            Value<double> value1 = const Value.absent(),
            Value<double?> value2 = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> measuredAt = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> sourceLabel = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementLogsCompanion(
            id: id,
            careRecipientId: careRecipientId,
            measurementType: measurementType,
            value1: value1,
            value2: value2,
            unit: unit,
            measuredAt: measuredAt,
            recordedAt: recordedAt,
            sourceType: sourceType,
            sourceLabel: sourceLabel,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required String measurementType,
            required double value1,
            Value<double?> value2 = const Value.absent(),
            required String unit,
            required DateTime measuredAt,
            required DateTime recordedAt,
            Value<String> sourceType = const Value.absent(),
            Value<String?> sourceLabel = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementLogsCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            measurementType: measurementType,
            value1: value1,
            value2: value2,
            unit: unit,
            measuredAt: measuredAt,
            recordedAt: recordedAt,
            sourceType: sourceType,
            sourceLabel: sourceLabel,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MeasurementLogsTable, MeasurementLog>(table),
                    $$MeasurementLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({careRecipientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable: $$MeasurementLogsTableReferences
                        ._careRecipientIdTable(db),
                    referencedColumn: $$MeasurementLogsTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MeasurementLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementLogsTable,
    MeasurementLog,
    $$MeasurementLogsTableFilterComposer,
    $$MeasurementLogsTableOrderingComposer,
    $$MeasurementLogsTableAnnotationComposer,
    $$MeasurementLogsTableCreateCompanionBuilder,
    $$MeasurementLogsTableUpdateCompanionBuilder,
    (MeasurementLog, $$MeasurementLogsTableReferences),
    MeasurementLog,
    PrefetchHooks Function({bool careRecipientId})>;
typedef $$AppointmentsTableCreateCompanionBuilder = AppointmentsCompanion
    Function({
  required String id,
  required String careRecipientId,
  Value<String?> providerOrFacility,
  Value<String?> purpose,
  required DateTime scheduledAt,
  Value<String?> notes,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppointmentsTableUpdateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<String?> providerOrFacility,
  Value<String?> purpose,
  Value<DateTime> scheduledAt,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) =>
      db.careRecipients
          .createAlias('appointments__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerOrFacility => $composableBuilder(
      column: $table.providerOrFacility,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerOrFacility => $composableBuilder(
      column: $table.providerOrFacility,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerOrFacility => $composableBuilder(
      column: $table.providerOrFacility, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (Appointment, $$AppointmentsTableReferences),
    Appointment,
    PrefetchHooks Function({bool careRecipientId})> {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<String?> providerOrFacility = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion(
            id: id,
            careRecipientId: careRecipientId,
            providerOrFacility: providerOrFacility,
            purpose: purpose,
            scheduledAt: scheduledAt,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            Value<String?> providerOrFacility = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            required DateTime scheduledAt,
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            providerOrFacility: providerOrFacility,
            purpose: purpose,
            scheduledAt: scheduledAt,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppointmentsTable, Appointment>(table),
                    $$AppointmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({careRecipientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable:
                        $$AppointmentsTableReferences._careRecipientIdTable(db),
                    referencedColumn: $$AppointmentsTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AppointmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (Appointment, $$AppointmentsTableReferences),
    Appointment,
    PrefetchHooks Function({bool careRecipientId})>;
typedef $$CareNotesTableCreateCompanionBuilder = CareNotesCompanion Function({
  required String id,
  required String careRecipientId,
  required DateTime observedAt,
  required DateTime recordedAt,
  required String originalText,
  Value<String?> structuredSummary,
  Value<String> sourceType,
  Value<String> reviewStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CareNotesTableUpdateCompanionBuilder = CareNotesCompanion Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<DateTime> observedAt,
  Value<DateTime> recordedAt,
  Value<String> originalText,
  Value<String?> structuredSummary,
  Value<String> sourceType,
  Value<String> reviewStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CareNotesTableReferences
    extends BaseReferences<_$AppDatabase, $CareNotesTable, CareNote> {
  $$CareNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) =>
      db.careRecipients
          .createAlias('care_notes__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CareNotesTableFilterComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get structuredSummary => $composableBuilder(
      column: $table.structuredSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalText => $composableBuilder(
      column: $table.originalText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get structuredSummary => $composableBuilder(
      column: $table.structuredSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => column);

  GeneratedColumn<String> get structuredSummary => $composableBuilder(
      column: $table.structuredSummary, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CareNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CareNotesTable,
    CareNote,
    $$CareNotesTableFilterComposer,
    $$CareNotesTableOrderingComposer,
    $$CareNotesTableAnnotationComposer,
    $$CareNotesTableCreateCompanionBuilder,
    $$CareNotesTableUpdateCompanionBuilder,
    (CareNote, $$CareNotesTableReferences),
    CareNote,
    PrefetchHooks Function({bool careRecipientId})> {
  $$CareNotesTableTableManager(_$AppDatabase db, $CareNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<DateTime> observedAt = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<String> originalText = const Value.absent(),
            Value<String?> structuredSummary = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> reviewStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CareNotesCompanion(
            id: id,
            careRecipientId: careRecipientId,
            observedAt: observedAt,
            recordedAt: recordedAt,
            originalText: originalText,
            structuredSummary: structuredSummary,
            sourceType: sourceType,
            reviewStatus: reviewStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required DateTime observedAt,
            required DateTime recordedAt,
            required String originalText,
            Value<String?> structuredSummary = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> reviewStatus = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CareNotesCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            observedAt: observedAt,
            recordedAt: recordedAt,
            originalText: originalText,
            structuredSummary: structuredSummary,
            sourceType: sourceType,
            reviewStatus: reviewStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CareNotesTable, CareNote>(table),
                    $$CareNotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({careRecipientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable:
                        $$CareNotesTableReferences._careRecipientIdTable(db),
                    referencedColumn:
                        $$CareNotesTableReferences._careRecipientIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CareNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CareNotesTable,
    CareNote,
    $$CareNotesTableFilterComposer,
    $$CareNotesTableOrderingComposer,
    $$CareNotesTableAnnotationComposer,
    $$CareNotesTableCreateCompanionBuilder,
    $$CareNotesTableUpdateCompanionBuilder,
    (CareNote, $$CareNotesTableReferences),
    CareNote,
    PrefetchHooks Function({bool careRecipientId})>;
typedef $$EmergencyEventsTableCreateCompanionBuilder = EmergencyEventsCompanion
    Function({
  required String id,
  required String careRecipientId,
  required DateTime triggeredAt,
  required String triggerType,
  Value<DateTime?> cancelledAt,
  Value<String?> selectedAction,
  Value<String> actionStatus,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$EmergencyEventsTableUpdateCompanionBuilder = EmergencyEventsCompanion
    Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<DateTime> triggeredAt,
  Value<String> triggerType,
  Value<DateTime?> cancelledAt,
  Value<String?> selectedAction,
  Value<String> actionStatus,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$EmergencyEventsTableReferences extends BaseReferences<
    _$AppDatabase, $EmergencyEventsTable, EmergencyEvent> {
  $$EmergencyEventsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) => db
      .careRecipients
      .createAlias('emergency_events__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EmergencyEventsTableFilterComposer
    extends Composer<_$AppDatabase, $EmergencyEventsTable> {
  $$EmergencyEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedAction => $composableBuilder(
      column: $table.selectedAction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionStatus => $composableBuilder(
      column: $table.actionStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmergencyEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmergencyEventsTable> {
  $$EmergencyEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedAction => $composableBuilder(
      column: $table.selectedAction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionStatus => $composableBuilder(
      column: $table.actionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmergencyEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmergencyEventsTable> {
  $$EmergencyEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => column);

  GeneratedColumn<String> get selectedAction => $composableBuilder(
      column: $table.selectedAction, builder: (column) => column);

  GeneratedColumn<String> get actionStatus => $composableBuilder(
      column: $table.actionStatus, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmergencyEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmergencyEventsTable,
    EmergencyEvent,
    $$EmergencyEventsTableFilterComposer,
    $$EmergencyEventsTableOrderingComposer,
    $$EmergencyEventsTableAnnotationComposer,
    $$EmergencyEventsTableCreateCompanionBuilder,
    $$EmergencyEventsTableUpdateCompanionBuilder,
    (EmergencyEvent, $$EmergencyEventsTableReferences),
    EmergencyEvent,
    PrefetchHooks Function({bool careRecipientId})> {
  $$EmergencyEventsTableTableManager(
      _$AppDatabase db, $EmergencyEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmergencyEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmergencyEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmergencyEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<DateTime> triggeredAt = const Value.absent(),
            Value<String> triggerType = const Value.absent(),
            Value<DateTime?> cancelledAt = const Value.absent(),
            Value<String?> selectedAction = const Value.absent(),
            Value<String> actionStatus = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmergencyEventsCompanion(
            id: id,
            careRecipientId: careRecipientId,
            triggeredAt: triggeredAt,
            triggerType: triggerType,
            cancelledAt: cancelledAt,
            selectedAction: selectedAction,
            actionStatus: actionStatus,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required DateTime triggeredAt,
            required String triggerType,
            Value<DateTime?> cancelledAt = const Value.absent(),
            Value<String?> selectedAction = const Value.absent(),
            Value<String> actionStatus = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EmergencyEventsCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            triggeredAt: triggeredAt,
            triggerType: triggerType,
            cancelledAt: cancelledAt,
            selectedAction: selectedAction,
            actionStatus: actionStatus,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$EmergencyEventsTable, EmergencyEvent>(table),
                    $$EmergencyEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({careRecipientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable: $$EmergencyEventsTableReferences
                        ._careRecipientIdTable(db),
                    referencedColumn: $$EmergencyEventsTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EmergencyEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EmergencyEventsTable,
    EmergencyEvent,
    $$EmergencyEventsTableFilterComposer,
    $$EmergencyEventsTableOrderingComposer,
    $$EmergencyEventsTableAnnotationComposer,
    $$EmergencyEventsTableCreateCompanionBuilder,
    $$EmergencyEventsTableUpdateCompanionBuilder,
    (EmergencyEvent, $$EmergencyEventsTableReferences),
    EmergencyEvent,
    PrefetchHooks Function({bool careRecipientId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTable, AppSetting>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsTable,
                        AppSetting>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$AiCapturesTableCreateCompanionBuilder = AiCapturesCompanion Function({
  required String id,
  required String careRecipientId,
  required String modality,
  required String originalText,
  required String engineId,
  required String modelId,
  required int latencyMs,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AiCapturesTableUpdateCompanionBuilder = AiCapturesCompanion Function({
  Value<String> id,
  Value<String> careRecipientId,
  Value<String> modality,
  Value<String> originalText,
  Value<String> engineId,
  Value<String> modelId,
  Value<int> latencyMs,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AiCapturesTableReferences
    extends BaseReferences<_$AppDatabase, $AiCapturesTable, AiCapture> {
  $$AiCapturesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CareRecipientsTable _careRecipientIdTable(_$AppDatabase db) =>
      db.careRecipients
          .createAlias('ai_captures__care_recipient_id__care_recipients__id');

  $$CareRecipientsTableProcessedTableManager get careRecipientId {
    final $_column = $_itemColumn<String>('care_recipient_id')!;

    final manager = $$CareRecipientsTableTableManager($_db, $_db.careRecipients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_careRecipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AiProposalsTable, List<AiProposal>>
      _aiProposalsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aiProposals,
              aliasName: 'ai_captures__id__ai_proposals__capture_id');

  $$AiProposalsTableProcessedTableManager get aiProposalsRefs {
    final manager = $$AiProposalsTableTableManager($_db, $_db.aiProposals)
        .filter((f) => f.captureId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_aiProposalsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AiCapturesTableFilterComposer
    extends Composer<_$AppDatabase, $AiCapturesTable> {
  $$AiCapturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modality => $composableBuilder(
      column: $table.modality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get engineId => $composableBuilder(
      column: $table.engineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get latencyMs => $composableBuilder(
      column: $table.latencyMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CareRecipientsTableFilterComposer get careRecipientId {
    final $$CareRecipientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableFilterComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> aiProposalsRefs(
      Expression<bool> Function($$AiProposalsTableFilterComposer f) f) {
    final $$AiProposalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiProposals,
        getReferencedColumn: (t) => t.captureId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiProposalsTableFilterComposer(
              $db: $db,
              $table: $db.aiProposals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AiCapturesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiCapturesTable> {
  $$AiCapturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modality => $composableBuilder(
      column: $table.modality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalText => $composableBuilder(
      column: $table.originalText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get engineId => $composableBuilder(
      column: $table.engineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get latencyMs => $composableBuilder(
      column: $table.latencyMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CareRecipientsTableOrderingComposer get careRecipientId {
    final $$CareRecipientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableOrderingComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiCapturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiCapturesTable> {
  $$AiCapturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => column);

  GeneratedColumn<String> get engineId =>
      $composableBuilder(column: $table.engineId, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CareRecipientsTableAnnotationComposer get careRecipientId {
    final $$CareRecipientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.careRecipientId,
        referencedTable: $db.careRecipients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CareRecipientsTableAnnotationComposer(
              $db: $db,
              $table: $db.careRecipients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> aiProposalsRefs<T extends Object>(
      Expression<T> Function($$AiProposalsTableAnnotationComposer a) f) {
    final $$AiProposalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiProposals,
        getReferencedColumn: (t) => t.captureId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiProposalsTableAnnotationComposer(
              $db: $db,
              $table: $db.aiProposals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AiCapturesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiCapturesTable,
    AiCapture,
    $$AiCapturesTableFilterComposer,
    $$AiCapturesTableOrderingComposer,
    $$AiCapturesTableAnnotationComposer,
    $$AiCapturesTableCreateCompanionBuilder,
    $$AiCapturesTableUpdateCompanionBuilder,
    (AiCapture, $$AiCapturesTableReferences),
    AiCapture,
    PrefetchHooks Function({bool careRecipientId, bool aiProposalsRefs})> {
  $$AiCapturesTableTableManager(_$AppDatabase db, $AiCapturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiCapturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiCapturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiCapturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> careRecipientId = const Value.absent(),
            Value<String> modality = const Value.absent(),
            Value<String> originalText = const Value.absent(),
            Value<String> engineId = const Value.absent(),
            Value<String> modelId = const Value.absent(),
            Value<int> latencyMs = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiCapturesCompanion(
            id: id,
            careRecipientId: careRecipientId,
            modality: modality,
            originalText: originalText,
            engineId: engineId,
            modelId: modelId,
            latencyMs: latencyMs,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String careRecipientId,
            required String modality,
            required String originalText,
            required String engineId,
            required String modelId,
            required int latencyMs,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiCapturesCompanion.insert(
            id: id,
            careRecipientId: careRecipientId,
            modality: modality,
            originalText: originalText,
            engineId: engineId,
            modelId: modelId,
            latencyMs: latencyMs,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AiCapturesTable, AiCapture>(table),
                    $$AiCapturesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {careRecipientId = false, aiProposalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (aiProposalsRefs) db.aiProposals],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (careRecipientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.careRecipientId,
                    referencedTable:
                        $$AiCapturesTableReferences._careRecipientIdTable(db),
                    referencedColumn: $$AiCapturesTableReferences
                        ._careRecipientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (aiProposalsRefs)
                    await $_getPrefetchedData<AiCapture, $AiCapturesTable,
                            AiProposal>(
                        currentTable: table,
                        referencedTable: $$AiCapturesTableReferences
                            ._aiProposalsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AiCapturesTableReferences(db, table, p0)
                                .aiProposalsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.captureId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AiCapturesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiCapturesTable,
    AiCapture,
    $$AiCapturesTableFilterComposer,
    $$AiCapturesTableOrderingComposer,
    $$AiCapturesTableAnnotationComposer,
    $$AiCapturesTableCreateCompanionBuilder,
    $$AiCapturesTableUpdateCompanionBuilder,
    (AiCapture, $$AiCapturesTableReferences),
    AiCapture,
    PrefetchHooks Function({bool careRecipientId, bool aiProposalsRefs})>;
typedef $$AiProposalsTableCreateCompanionBuilder = AiProposalsCompanion
    Function({
  required String id,
  required String captureId,
  required String kind,
  required String payloadJson,
  Value<String?> sourceQuote,
  Value<String?> flag,
  required String status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AiProposalsTableUpdateCompanionBuilder = AiProposalsCompanion
    Function({
  Value<String> id,
  Value<String> captureId,
  Value<String> kind,
  Value<String> payloadJson,
  Value<String?> sourceQuote,
  Value<String?> flag,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AiProposalsTableReferences
    extends BaseReferences<_$AppDatabase, $AiProposalsTable, AiProposal> {
  $$AiProposalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AiCapturesTable _captureIdTable(_$AppDatabase db) =>
      db.aiCaptures.createAlias('ai_proposals__capture_id__ai_captures__id');

  $$AiCapturesTableProcessedTableManager get captureId {
    final $_column = $_itemColumn<String>('capture_id')!;

    final manager = $$AiCapturesTableTableManager($_db, $_db.aiCaptures)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_captureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AiProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceQuote => $composableBuilder(
      column: $table.sourceQuote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$AiCapturesTableFilterComposer get captureId {
    final $$AiCapturesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.captureId,
        referencedTable: $db.aiCaptures,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiCapturesTableFilterComposer(
              $db: $db,
              $table: $db.aiCaptures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceQuote => $composableBuilder(
      column: $table.sourceQuote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$AiCapturesTableOrderingComposer get captureId {
    final $$AiCapturesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.captureId,
        referencedTable: $db.aiCaptures,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiCapturesTableOrderingComposer(
              $db: $db,
              $table: $db.aiCaptures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get sourceQuote => $composableBuilder(
      column: $table.sourceQuote, builder: (column) => column);

  GeneratedColumn<String> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AiCapturesTableAnnotationComposer get captureId {
    final $$AiCapturesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.captureId,
        referencedTable: $db.aiCaptures,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiCapturesTableAnnotationComposer(
              $db: $db,
              $table: $db.aiCaptures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiProposalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiProposalsTable,
    AiProposal,
    $$AiProposalsTableFilterComposer,
    $$AiProposalsTableOrderingComposer,
    $$AiProposalsTableAnnotationComposer,
    $$AiProposalsTableCreateCompanionBuilder,
    $$AiProposalsTableUpdateCompanionBuilder,
    (AiProposal, $$AiProposalsTableReferences),
    AiProposal,
    PrefetchHooks Function({bool captureId})> {
  $$AiProposalsTableTableManager(_$AppDatabase db, $AiProposalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProposalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProposalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> captureId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> sourceQuote = const Value.absent(),
            Value<String?> flag = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProposalsCompanion(
            id: id,
            captureId: captureId,
            kind: kind,
            payloadJson: payloadJson,
            sourceQuote: sourceQuote,
            flag: flag,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String captureId,
            required String kind,
            required String payloadJson,
            Value<String?> sourceQuote = const Value.absent(),
            Value<String?> flag = const Value.absent(),
            required String status,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProposalsCompanion.insert(
            id: id,
            captureId: captureId,
            kind: kind,
            payloadJson: payloadJson,
            sourceQuote: sourceQuote,
            flag: flag,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AiProposalsTable, AiProposal>(table),
                    $$AiProposalsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({captureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (captureId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.captureId,
                    referencedTable:
                        $$AiProposalsTableReferences._captureIdTable(db),
                    referencedColumn:
                        $$AiProposalsTableReferences._captureIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AiProposalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiProposalsTable,
    AiProposal,
    $$AiProposalsTableFilterComposer,
    $$AiProposalsTableOrderingComposer,
    $$AiProposalsTableAnnotationComposer,
    $$AiProposalsTableCreateCompanionBuilder,
    $$AiProposalsTableUpdateCompanionBuilder,
    (AiProposal, $$AiProposalsTableReferences),
    AiProposal,
    PrefetchHooks Function({bool captureId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CareRecipientsTableTableManager get careRecipients =>
      $$CareRecipientsTableTableManager(_db, _db.careRecipients);
  $$FamilyContactsTableTableManager get familyContacts =>
      $$FamilyContactsTableTableManager(_db, _db.familyContacts);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(_db, _db.medicationSchedules);
  $$MedicationOccurrencesTableTableManager get medicationOccurrences =>
      $$MedicationOccurrencesTableTableManager(_db, _db.medicationOccurrences);
  $$MeasurementLogsTableTableManager get measurementLogs =>
      $$MeasurementLogsTableTableManager(_db, _db.measurementLogs);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$CareNotesTableTableManager get careNotes =>
      $$CareNotesTableTableManager(_db, _db.careNotes);
  $$EmergencyEventsTableTableManager get emergencyEvents =>
      $$EmergencyEventsTableTableManager(_db, _db.emergencyEvents);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AiCapturesTableTableManager get aiCaptures =>
      $$AiCapturesTableTableManager(_db, _db.aiCaptures);
  $$AiProposalsTableTableManager get aiProposals =>
      $$AiProposalsTableTableManager(_db, _db.aiProposals);
}
