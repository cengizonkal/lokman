// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodTypeMeta = const VerificationMeta(
    'bloodType',
  );
  @override
  late final GeneratedColumn<String> bloodType = GeneratedColumn<String>(
    'blood_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorIndexMeta = const VerificationMeta(
    'colorIndex',
  );
  @override
  late final GeneratedColumn<int> colorIndex = GeneratedColumn<int>(
    'color_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    birthDate,
    gender,
    bloodType,
    colorIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('blood_type')) {
      context.handle(
        _bloodTypeMeta,
        bloodType.isAcceptableOrUnknown(data['blood_type']!, _bloodTypeMeta),
      );
    }
    if (data.containsKey('color_index')) {
      context.handle(
        _colorIndexMeta,
        colorIndex.isAcceptableOrUnknown(data['color_index']!, _colorIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      bloodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_type'],
      ),
      colorIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;

  /// `female`, `male` ya da boş.
  final String? gender;
  final String? bloodType;
  final int colorIndex;
  final DateTime createdAt;
  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.bloodType,
    required this.colorIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || bloodType != null) {
      map['blood_type'] = Variable<String>(bloodType);
    }
    map['color_index'] = Variable<int>(colorIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      bloodType: bloodType == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodType),
      colorIndex: Value(colorIndex),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: serializer.fromJson<String?>(json['gender']),
      bloodType: serializer.fromJson<String?>(json['bloodType']),
      colorIndex: serializer.fromJson<int>(json['colorIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<String?>(gender),
      'bloodType': serializer.toJson<String?>(bloodType),
      'colorIndex': serializer.toJson<int>(colorIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> bloodType = const Value.absent(),
    int? colorIndex,
    DateTime? createdAt,
  }) => Profile(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    gender: gender.present ? gender.value : this.gender,
    bloodType: bloodType.present ? bloodType.value : this.bloodType,
    colorIndex: colorIndex ?? this.colorIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      bloodType: data.bloodType.present ? data.bloodType.value : this.bloodType,
      colorIndex: data.colorIndex.present
          ? data.colorIndex.value
          : this.colorIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    birthDate,
    gender,
    bloodType,
    colorIndex,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.bloodType == this.bloodType &&
          other.colorIndex == this.colorIndex &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<DateTime?> birthDate;
  final Value<String?> gender;
  final Value<String?> bloodType;
  final Value<int> colorIndex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    this.lastName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firstName = Value(firstName);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<String>? bloodType,
    Expression<int>? colorIndex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (bloodType != null) 'blood_type': bloodType,
      if (colorIndex != null) 'color_index': colorIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<DateTime?>? birthDate,
    Value<String?>? gender,
    Value<String?>? bloodType,
    Value<int>? colorIndex,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      colorIndex: colorIndex ?? this.colorIndex,
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
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (bloodType.present) {
      map['blood_type'] = Variable<String>(bloodType.value);
    }
    if (colorIndex.present) {
      map['color_index'] = Variable<int>(colorIndex.value);
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
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileLinksTable extends ProfileLinks
    with TableInfo<$ProfileLinksTable, ProfileLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<String> system = GeneratedColumn<String>(
    'system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationNameMeta = const VerificationMeta(
    'organizationName',
  );
  @override
  late final GeneratedColumn<String> organizationName = GeneratedColumn<String>(
    'organization_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    system,
    value,
    organizationName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('system')) {
      context.handle(
        _systemMeta,
        system.isAcceptableOrUnknown(data['system']!, _systemMeta),
      );
    } else if (isInserting) {
      context.missing(_systemMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('organization_name')) {
      context.handle(
        _organizationNameMeta,
        organizationName.isAcceptableOrUnknown(
          data['organization_name']!,
          _organizationNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {system, value},
  ];
  @override
  ProfileLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      system: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      organizationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_name'],
      ),
    );
  }

  @override
  $ProfileLinksTable createAlias(String alias) {
    return $ProfileLinksTable(attachedDatabase, alias);
  }
}

class ProfileLink extends DataClass implements Insertable<ProfileLink> {
  final String id;
  final String profileId;
  final String system;
  final String value;
  final String? organizationName;
  const ProfileLink({
    required this.id,
    required this.profileId,
    required this.system,
    required this.value,
    this.organizationName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['system'] = Variable<String>(system);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || organizationName != null) {
      map['organization_name'] = Variable<String>(organizationName);
    }
    return map;
  }

  ProfileLinksCompanion toCompanion(bool nullToAbsent) {
    return ProfileLinksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      system: Value(system),
      value: Value(value),
      organizationName: organizationName == null && nullToAbsent
          ? const Value.absent()
          : Value(organizationName),
    );
  }

  factory ProfileLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileLink(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      system: serializer.fromJson<String>(json['system']),
      value: serializer.fromJson<String>(json['value']),
      organizationName: serializer.fromJson<String?>(json['organizationName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'system': serializer.toJson<String>(system),
      'value': serializer.toJson<String>(value),
      'organizationName': serializer.toJson<String?>(organizationName),
    };
  }

  ProfileLink copyWith({
    String? id,
    String? profileId,
    String? system,
    String? value,
    Value<String?> organizationName = const Value.absent(),
  }) => ProfileLink(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    system: system ?? this.system,
    value: value ?? this.value,
    organizationName: organizationName.present
        ? organizationName.value
        : this.organizationName,
  );
  ProfileLink copyWithCompanion(ProfileLinksCompanion data) {
    return ProfileLink(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      system: data.system.present ? data.system.value : this.system,
      value: data.value.present ? data.value.value : this.value,
      organizationName: data.organizationName.present
          ? data.organizationName.value
          : this.organizationName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLink(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('system: $system, ')
          ..write('value: $value, ')
          ..write('organizationName: $organizationName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, system, value, organizationName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLink &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.system == this.system &&
          other.value == this.value &&
          other.organizationName == this.organizationName);
}

class ProfileLinksCompanion extends UpdateCompanion<ProfileLink> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> system;
  final Value<String> value;
  final Value<String?> organizationName;
  final Value<int> rowid;
  const ProfileLinksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.system = const Value.absent(),
    this.value = const Value.absent(),
    this.organizationName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileLinksCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String system,
    required String value,
    this.organizationName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       system = Value(system),
       value = Value(value);
  static Insertable<ProfileLink> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? system,
    Expression<String>? value,
    Expression<String>? organizationName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (system != null) 'system': system,
      if (value != null) 'value': value,
      if (organizationName != null) 'organization_name': organizationName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? system,
    Value<String>? value,
    Value<String?>? organizationName,
    Value<int>? rowid,
  }) {
    return ProfileLinksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      system: system ?? this.system,
      value: value ?? this.value,
      organizationName: organizationName ?? this.organizationName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (system.present) {
      map['system'] = Variable<String>(system.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (organizationName.present) {
      map['organization_name'] = Variable<String>(organizationName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLinksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('system: $system, ')
          ..write('value: $value, ')
          ..write('organizationName: $organizationName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _practitionerMeta = const VerificationMeta(
    'practitioner',
  );
  @override
  late final GeneratedColumn<String> practitioner = GeneratedColumn<String>(
    'practitioner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _complaintMeta = const VerificationMeta(
    'complaint',
  );
  @override
  late final GeneratedColumn<String> complaint = GeneratedColumn<String>(
    'complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _findingsMeta = const VerificationMeta(
    'findings',
  );
  @override
  late final GeneratedColumn<String> findings = GeneratedColumn<String>(
    'findings',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    date,
    practitioner,
    location,
    complaint,
    findings,
    plan,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Encounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('practitioner')) {
      context.handle(
        _practitionerMeta,
        practitioner.isAcceptableOrUnknown(
          data['practitioner']!,
          _practitionerMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('complaint')) {
      context.handle(
        _complaintMeta,
        complaint.isAcceptableOrUnknown(data['complaint']!, _complaintMeta),
      );
    }
    if (data.containsKey('findings')) {
      context.handle(
        _findingsMeta,
        findings.isAcceptableOrUnknown(data['findings']!, _findingsMeta),
      );
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      practitioner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practitioner'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      complaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}complaint'],
      ),
      findings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}findings'],
      ),
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final DateTime date;
  final String? practitioner;

  /// Gidilen hastane / klinik (FHIR `Encounter.serviceProvider`).
  final String? location;
  final String? complaint;
  final String? findings;

  /// Hekimin hastaya önerileri.
  final String? plan;

  /// Kullanıcının kendi notu.
  final String? note;
  const Encounter({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.date,
    this.practitioner,
    this.location,
    this.complaint,
    this.findings,
    this.plan,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || practitioner != null) {
      map['practitioner'] = Variable<String>(practitioner);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || complaint != null) {
      map['complaint'] = Variable<String>(complaint);
    }
    if (!nullToAbsent || findings != null) {
      map['findings'] = Variable<String>(findings);
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      date: Value(date),
      practitioner: practitioner == null && nullToAbsent
          ? const Value.absent()
          : Value(practitioner),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      complaint: complaint == null && nullToAbsent
          ? const Value.absent()
          : Value(complaint),
      findings: findings == null && nullToAbsent
          ? const Value.absent()
          : Value(findings),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Encounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      date: serializer.fromJson<DateTime>(json['date']),
      practitioner: serializer.fromJson<String?>(json['practitioner']),
      location: serializer.fromJson<String?>(json['location']),
      complaint: serializer.fromJson<String?>(json['complaint']),
      findings: serializer.fromJson<String?>(json['findings']),
      plan: serializer.fromJson<String?>(json['plan']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'date': serializer.toJson<DateTime>(date),
      'practitioner': serializer.toJson<String?>(practitioner),
      'location': serializer.toJson<String?>(location),
      'complaint': serializer.toJson<String?>(complaint),
      'findings': serializer.toJson<String?>(findings),
      'plan': serializer.toJson<String?>(plan),
      'note': serializer.toJson<String?>(note),
    };
  }

  Encounter copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? date,
    Value<String?> practitioner = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> complaint = const Value.absent(),
    Value<String?> findings = const Value.absent(),
    Value<String?> plan = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Encounter(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    date: date ?? this.date,
    practitioner: practitioner.present ? practitioner.value : this.practitioner,
    location: location.present ? location.value : this.location,
    complaint: complaint.present ? complaint.value : this.complaint,
    findings: findings.present ? findings.value : this.findings,
    plan: plan.present ? plan.value : this.plan,
    note: note.present ? note.value : this.note,
  );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      date: data.date.present ? data.date.value : this.date,
      practitioner: data.practitioner.present
          ? data.practitioner.value
          : this.practitioner,
      location: data.location.present ? data.location.value : this.location,
      complaint: data.complaint.present ? data.complaint.value : this.complaint,
      findings: data.findings.present ? data.findings.value : this.findings,
      plan: data.plan.present ? data.plan.value : this.plan,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('practitioner: $practitioner, ')
          ..write('location: $location, ')
          ..write('complaint: $complaint, ')
          ..write('findings: $findings, ')
          ..write('plan: $plan, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    date,
    practitioner,
    location,
    complaint,
    findings,
    plan,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.date == this.date &&
          other.practitioner == this.practitioner &&
          other.location == this.location &&
          other.complaint == this.complaint &&
          other.findings == this.findings &&
          other.plan == this.plan &&
          other.note == this.note);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> date;
  final Value<String?> practitioner;
  final Value<String?> location;
  final Value<String?> complaint;
  final Value<String?> findings;
  final Value<String?> plan;
  final Value<String?> note;
  final Value<int> rowid;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.date = const Value.absent(),
    this.practitioner = const Value.absent(),
    this.location = const Value.absent(),
    this.complaint = const Value.absent(),
    this.findings = const Value.absent(),
    this.plan = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncountersCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime date,
    this.practitioner = const Value.absent(),
    this.location = const Value.absent(),
    this.complaint = const Value.absent(),
    this.findings = const Value.absent(),
    this.plan = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       date = Value(date);
  static Insertable<Encounter> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? date,
    Expression<String>? practitioner,
    Expression<String>? location,
    Expression<String>? complaint,
    Expression<String>? findings,
    Expression<String>? plan,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (date != null) 'date': date,
      if (practitioner != null) 'practitioner': practitioner,
      if (location != null) 'location': location,
      if (complaint != null) 'complaint': complaint,
      if (findings != null) 'findings': findings,
      if (plan != null) 'plan': plan,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncountersCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? date,
    Value<String?>? practitioner,
    Value<String?>? location,
    Value<String?>? complaint,
    Value<String?>? findings,
    Value<String?>? plan,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return EncountersCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      practitioner: practitioner ?? this.practitioner,
      location: location ?? this.location,
      complaint: complaint ?? this.complaint,
      findings: findings ?? this.findings,
      plan: plan ?? this.plan,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (practitioner.present) {
      map['practitioner'] = Variable<String>(practitioner.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (complaint.present) {
      map['complaint'] = Variable<String>(complaint.value);
    }
    if (findings.present) {
      map['findings'] = Variable<String>(findings.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('date: $date, ')
          ..write('practitioner: $practitioner, ')
          ..write('location: $location, ')
          ..write('complaint: $complaint, ')
          ..write('findings: $findings, ')
          ..write('plan: $plan, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosesTable extends Diagnoses
    with TableInfo<$DiagnosesTable, Diagnosis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
    'encounter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeSystemMeta = const VerificationMeta(
    'codeSystem',
  );
  @override
  late final GeneratedColumn<String> codeSystem = GeneratedColumn<String>(
    'code_system',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verificationMeta = const VerificationMeta(
    'verification',
  );
  @override
  late final GeneratedColumn<String> verification = GeneratedColumn<String>(
    'verification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    encounterId,
    date,
    code,
    codeSystem,
    name,
    verification,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnoses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Diagnosis> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('code_system')) {
      context.handle(
        _codeSystemMeta,
        codeSystem.isAcceptableOrUnknown(data['code_system']!, _codeSystemMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('verification')) {
      context.handle(
        _verificationMeta,
        verification.isAcceptableOrUnknown(
          data['verification']!,
          _verificationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Diagnosis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Diagnosis(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encounter_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      codeSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_system'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      verification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification'],
      )!,
    );
  }

  @override
  $DiagnosesTable createAlias(String alias) {
    return $DiagnosesTable(attachedDatabase, alias);
  }
}

class Diagnosis extends DataClass implements Insertable<Diagnosis> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String? encounterId;
  final DateTime? date;
  final String? code;

  /// [code]'un kod sistemi, FHIR `coding.system` adresiyle (ICD-11 seçilince
  /// `http://id.who.int/icd/release/11/mms`). Dışarıdan gelen kayıtlarda
  /// kaynağın sistemi olduğu gibi saklanır; boşsa kod serbest metindir.
  final String? codeSystem;
  final String name;

  /// `provisional` (ön tanı) ya da `confirmed` (kesin tanı).
  final String verification;
  const Diagnosis({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    this.encounterId,
    this.date,
    this.code,
    this.codeSystem,
    required this.name,
    required this.verification,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || encounterId != null) {
      map['encounter_id'] = Variable<String>(encounterId);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || codeSystem != null) {
      map['code_system'] = Variable<String>(codeSystem);
    }
    map['name'] = Variable<String>(name);
    map['verification'] = Variable<String>(verification);
    return map;
  }

  DiagnosesCompanion toCompanion(bool nullToAbsent) {
    return DiagnosesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      encounterId: encounterId == null && nullToAbsent
          ? const Value.absent()
          : Value(encounterId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      codeSystem: codeSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(codeSystem),
      name: Value(name),
      verification: Value(verification),
    );
  }

  factory Diagnosis.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Diagnosis(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      encounterId: serializer.fromJson<String?>(json['encounterId']),
      date: serializer.fromJson<DateTime?>(json['date']),
      code: serializer.fromJson<String?>(json['code']),
      codeSystem: serializer.fromJson<String?>(json['codeSystem']),
      name: serializer.fromJson<String>(json['name']),
      verification: serializer.fromJson<String>(json['verification']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'encounterId': serializer.toJson<String?>(encounterId),
      'date': serializer.toJson<DateTime?>(date),
      'code': serializer.toJson<String?>(code),
      'codeSystem': serializer.toJson<String?>(codeSystem),
      'name': serializer.toJson<String>(name),
      'verification': serializer.toJson<String>(verification),
    };
  }

  Diagnosis copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    Value<String?> encounterId = const Value.absent(),
    Value<DateTime?> date = const Value.absent(),
    Value<String?> code = const Value.absent(),
    Value<String?> codeSystem = const Value.absent(),
    String? name,
    String? verification,
  }) => Diagnosis(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    encounterId: encounterId.present ? encounterId.value : this.encounterId,
    date: date.present ? date.value : this.date,
    code: code.present ? code.value : this.code,
    codeSystem: codeSystem.present ? codeSystem.value : this.codeSystem,
    name: name ?? this.name,
    verification: verification ?? this.verification,
  );
  Diagnosis copyWithCompanion(DiagnosesCompanion data) {
    return Diagnosis(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      date: data.date.present ? data.date.value : this.date,
      code: data.code.present ? data.code.value : this.code,
      codeSystem: data.codeSystem.present
          ? data.codeSystem.value
          : this.codeSystem,
      name: data.name.present ? data.name.value : this.name,
      verification: data.verification.present
          ? data.verification.value
          : this.verification,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Diagnosis(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('encounterId: $encounterId, ')
          ..write('date: $date, ')
          ..write('code: $code, ')
          ..write('codeSystem: $codeSystem, ')
          ..write('name: $name, ')
          ..write('verification: $verification')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    encounterId,
    date,
    code,
    codeSystem,
    name,
    verification,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Diagnosis &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.encounterId == this.encounterId &&
          other.date == this.date &&
          other.code == this.code &&
          other.codeSystem == this.codeSystem &&
          other.name == this.name &&
          other.verification == this.verification);
}

class DiagnosesCompanion extends UpdateCompanion<Diagnosis> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String?> encounterId;
  final Value<DateTime?> date;
  final Value<String?> code;
  final Value<String?> codeSystem;
  final Value<String> name;
  final Value<String> verification;
  final Value<int> rowid;
  const DiagnosesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.date = const Value.absent(),
    this.code = const Value.absent(),
    this.codeSystem = const Value.absent(),
    this.name = const Value.absent(),
    this.verification = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.date = const Value.absent(),
    this.code = const Value.absent(),
    this.codeSystem = const Value.absent(),
    required String name,
    this.verification = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name);
  static Insertable<Diagnosis> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? encounterId,
    Expression<DateTime>? date,
    Expression<String>? code,
    Expression<String>? codeSystem,
    Expression<String>? name,
    Expression<String>? verification,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (encounterId != null) 'encounter_id': encounterId,
      if (date != null) 'date': date,
      if (code != null) 'code': code,
      if (codeSystem != null) 'code_system': codeSystem,
      if (name != null) 'name': name,
      if (verification != null) 'verification': verification,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String?>? encounterId,
    Value<DateTime?>? date,
    Value<String?>? code,
    Value<String?>? codeSystem,
    Value<String>? name,
    Value<String>? verification,
    Value<int>? rowid,
  }) {
    return DiagnosesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      encounterId: encounterId ?? this.encounterId,
      date: date ?? this.date,
      code: code ?? this.code,
      codeSystem: codeSystem ?? this.codeSystem,
      name: name ?? this.name,
      verification: verification ?? this.verification,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (codeSystem.present) {
      map['code_system'] = Variable<String>(codeSystem.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (verification.present) {
      map['verification'] = Variable<String>(verification.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('encounterId: $encounterId, ')
          ..write('date: $date, ')
          ..write('code: $code, ')
          ..write('codeSystem: $codeSystem, ')
          ..write('name: $name, ')
          ..write('verification: $verification, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<String> dose = GeneratedColumn<String>(
    'dose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _timesOfDayMeta = const VerificationMeta(
    'timesOfDay',
  );
  @override
  late final GeneratedColumn<String> timesOfDay = GeneratedColumn<String>(
    'times_of_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atcCodeMeta = const VerificationMeta(
    'atcCode',
  );
  @override
  late final GeneratedColumn<String> atcCode = GeneratedColumn<String>(
    'atc_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescriptionRefMeta = const VerificationMeta(
    'prescriptionRef',
  );
  @override
  late final GeneratedColumn<String> prescriptionRef = GeneratedColumn<String>(
    'prescription_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
    'encounter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stoppedAtMeta = const VerificationMeta(
    'stoppedAt',
  );
  @override
  late final GeneratedColumn<DateTime> stoppedAt = GeneratedColumn<DateTime>(
    'stopped_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    name,
    dose,
    timesOfDay,
    startDate,
    durationDays,
    note,
    atcCode,
    prescriptionRef,
    encounterId,
    stoppedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    }
    if (data.containsKey('times_of_day')) {
      context.handle(
        _timesOfDayMeta,
        timesOfDay.isAcceptableOrUnknown(
          data['times_of_day']!,
          _timesOfDayMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('atc_code')) {
      context.handle(
        _atcCodeMeta,
        atcCode.isAcceptableOrUnknown(data['atc_code']!, _atcCodeMeta),
      );
    }
    if (data.containsKey('prescription_ref')) {
      context.handle(
        _prescriptionRefMeta,
        prescriptionRef.isAcceptableOrUnknown(
          data['prescription_ref']!,
          _prescriptionRefMeta,
        ),
      );
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    }
    if (data.containsKey('stopped_at')) {
      context.handle(
        _stoppedAtMeta,
        stoppedAt.isAcceptableOrUnknown(data['stopped_at']!, _stoppedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose'],
      )!,
      timesOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_of_day'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      atcCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}atc_code'],
      ),
      prescriptionRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_ref'],
      ),
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encounter_id'],
      ),
      stoppedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stopped_at'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String name;

  /// Serbest metin doz: "1 tablet", "5 ml".
  final String dose;

  /// Virgülle ayrılmış saatler: "08:00,20:00".
  final String timesOfDay;
  final DateTime startDate;

  /// Gün olarak süre; boşsa sürekli kullanım.
  final int? durationDays;
  final String? note;
  final String? atcCode;

  /// Aynı reçetedeki kalemleri gruplar (`MedicationRequest.groupIdentifier`).
  final String? prescriptionRef;

  /// İlacın yazıldığı muayene (`MedicationRequest.encounter`).
  final String? encounterId;
  final DateTime? stoppedAt;
  const Medication({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.name,
    required this.dose,
    required this.timesOfDay,
    required this.startDate,
    this.durationDays,
    this.note,
    this.atcCode,
    this.prescriptionRef,
    this.encounterId,
    this.stoppedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    map['dose'] = Variable<String>(dose);
    map['times_of_day'] = Variable<String>(timesOfDay);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || durationDays != null) {
      map['duration_days'] = Variable<int>(durationDays);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || atcCode != null) {
      map['atc_code'] = Variable<String>(atcCode);
    }
    if (!nullToAbsent || prescriptionRef != null) {
      map['prescription_ref'] = Variable<String>(prescriptionRef);
    }
    if (!nullToAbsent || encounterId != null) {
      map['encounter_id'] = Variable<String>(encounterId);
    }
    if (!nullToAbsent || stoppedAt != null) {
      map['stopped_at'] = Variable<DateTime>(stoppedAt);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      name: Value(name),
      dose: Value(dose),
      timesOfDay: Value(timesOfDay),
      startDate: Value(startDate),
      durationDays: durationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(durationDays),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      atcCode: atcCode == null && nullToAbsent
          ? const Value.absent()
          : Value(atcCode),
      prescriptionRef: prescriptionRef == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriptionRef),
      encounterId: encounterId == null && nullToAbsent
          ? const Value.absent()
          : Value(encounterId),
      stoppedAt: stoppedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(stoppedAt),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      dose: serializer.fromJson<String>(json['dose']),
      timesOfDay: serializer.fromJson<String>(json['timesOfDay']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      durationDays: serializer.fromJson<int?>(json['durationDays']),
      note: serializer.fromJson<String?>(json['note']),
      atcCode: serializer.fromJson<String?>(json['atcCode']),
      prescriptionRef: serializer.fromJson<String?>(json['prescriptionRef']),
      encounterId: serializer.fromJson<String?>(json['encounterId']),
      stoppedAt: serializer.fromJson<DateTime?>(json['stoppedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'dose': serializer.toJson<String>(dose),
      'timesOfDay': serializer.toJson<String>(timesOfDay),
      'startDate': serializer.toJson<DateTime>(startDate),
      'durationDays': serializer.toJson<int?>(durationDays),
      'note': serializer.toJson<String?>(note),
      'atcCode': serializer.toJson<String?>(atcCode),
      'prescriptionRef': serializer.toJson<String?>(prescriptionRef),
      'encounterId': serializer.toJson<String?>(encounterId),
      'stoppedAt': serializer.toJson<DateTime?>(stoppedAt),
    };
  }

  Medication copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? name,
    String? dose,
    String? timesOfDay,
    DateTime? startDate,
    Value<int?> durationDays = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> atcCode = const Value.absent(),
    Value<String?> prescriptionRef = const Value.absent(),
    Value<String?> encounterId = const Value.absent(),
    Value<DateTime?> stoppedAt = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    dose: dose ?? this.dose,
    timesOfDay: timesOfDay ?? this.timesOfDay,
    startDate: startDate ?? this.startDate,
    durationDays: durationDays.present ? durationDays.value : this.durationDays,
    note: note.present ? note.value : this.note,
    atcCode: atcCode.present ? atcCode.value : this.atcCode,
    prescriptionRef: prescriptionRef.present
        ? prescriptionRef.value
        : this.prescriptionRef,
    encounterId: encounterId.present ? encounterId.value : this.encounterId,
    stoppedAt: stoppedAt.present ? stoppedAt.value : this.stoppedAt,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      dose: data.dose.present ? data.dose.value : this.dose,
      timesOfDay: data.timesOfDay.present
          ? data.timesOfDay.value
          : this.timesOfDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      note: data.note.present ? data.note.value : this.note,
      atcCode: data.atcCode.present ? data.atcCode.value : this.atcCode,
      prescriptionRef: data.prescriptionRef.present
          ? data.prescriptionRef.value
          : this.prescriptionRef,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      stoppedAt: data.stoppedAt.present ? data.stoppedAt.value : this.stoppedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('dose: $dose, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('startDate: $startDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('note: $note, ')
          ..write('atcCode: $atcCode, ')
          ..write('prescriptionRef: $prescriptionRef, ')
          ..write('encounterId: $encounterId, ')
          ..write('stoppedAt: $stoppedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    name,
    dose,
    timesOfDay,
    startDate,
    durationDays,
    note,
    atcCode,
    prescriptionRef,
    encounterId,
    stoppedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.dose == this.dose &&
          other.timesOfDay == this.timesOfDay &&
          other.startDate == this.startDate &&
          other.durationDays == this.durationDays &&
          other.note == this.note &&
          other.atcCode == this.atcCode &&
          other.prescriptionRef == this.prescriptionRef &&
          other.encounterId == this.encounterId &&
          other.stoppedAt == this.stoppedAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<String> dose;
  final Value<String> timesOfDay;
  final Value<DateTime> startDate;
  final Value<int?> durationDays;
  final Value<String?> note;
  final Value<String?> atcCode;
  final Value<String?> prescriptionRef;
  final Value<String?> encounterId;
  final Value<DateTime?> stoppedAt;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.dose = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.note = const Value.absent(),
    this.atcCode = const Value.absent(),
    this.prescriptionRef = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.stoppedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String name,
    this.dose = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    required DateTime startDate,
    this.durationDays = const Value.absent(),
    this.note = const Value.absent(),
    this.atcCode = const Value.absent(),
    this.prescriptionRef = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.stoppedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       startDate = Value(startDate);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? dose,
    Expression<String>? timesOfDay,
    Expression<DateTime>? startDate,
    Expression<int>? durationDays,
    Expression<String>? note,
    Expression<String>? atcCode,
    Expression<String>? prescriptionRef,
    Expression<String>? encounterId,
    Expression<DateTime>? stoppedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (dose != null) 'dose': dose,
      if (timesOfDay != null) 'times_of_day': timesOfDay,
      if (startDate != null) 'start_date': startDate,
      if (durationDays != null) 'duration_days': durationDays,
      if (note != null) 'note': note,
      if (atcCode != null) 'atc_code': atcCode,
      if (prescriptionRef != null) 'prescription_ref': prescriptionRef,
      if (encounterId != null) 'encounter_id': encounterId,
      if (stoppedAt != null) 'stopped_at': stoppedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<String>? dose,
    Value<String>? timesOfDay,
    Value<DateTime>? startDate,
    Value<int?>? durationDays,
    Value<String?>? note,
    Value<String?>? atcCode,
    Value<String?>? prescriptionRef,
    Value<String?>? encounterId,
    Value<DateTime?>? stoppedAt,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      note: note ?? this.note,
      atcCode: atcCode ?? this.atcCode,
      prescriptionRef: prescriptionRef ?? this.prescriptionRef,
      encounterId: encounterId ?? this.encounterId,
      stoppedAt: stoppedAt ?? this.stoppedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dose.present) {
      map['dose'] = Variable<String>(dose.value);
    }
    if (timesOfDay.present) {
      map['times_of_day'] = Variable<String>(timesOfDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (atcCode.present) {
      map['atc_code'] = Variable<String>(atcCode.value);
    }
    if (prescriptionRef.present) {
      map['prescription_ref'] = Variable<String>(prescriptionRef.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (stoppedAt.present) {
      map['stopped_at'] = Variable<DateTime>(stoppedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('dose: $dose, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('startDate: $startDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('note: $note, ')
          ..write('atcCode: $atcCode, ')
          ..write('prescriptionRef: $prescriptionRef, ')
          ..write('encounterId: $encounterId, ')
          ..write('stoppedAt: $stoppedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseEventsTable extends DoseEvents
    with TableInfo<$DoseEventsTable, DoseEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedAtMeta = const VerificationMeta(
    'markedAt',
  );
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
    'marked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    scheduledAt,
    status,
    markedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('marked_at')) {
      context.handle(
        _markedAtMeta,
        markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {medicationId, scheduledAt},
  ];
  @override
  DoseEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      markedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}marked_at'],
      )!,
    );
  }

  @override
  $DoseEventsTable createAlias(String alias) {
    return $DoseEventsTable(attachedDatabase, alias);
  }
}

class DoseEvent extends DataClass implements Insertable<DoseEvent> {
  final String id;
  final String medicationId;
  final DateTime scheduledAt;

  /// `taken` ya da `skipped`.
  final String status;
  final DateTime markedAt;
  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.scheduledAt,
    required this.status,
    required this.markedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_id'] = Variable<String>(medicationId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['status'] = Variable<String>(status);
    map['marked_at'] = Variable<DateTime>(markedAt);
    return map;
  }

  DoseEventsCompanion toCompanion(bool nullToAbsent) {
    return DoseEventsCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      markedAt: Value(markedAt),
    );
  }

  factory DoseEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseEvent(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      markedAt: serializer.fromJson<DateTime>(json['markedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String>(medicationId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'markedAt': serializer.toJson<DateTime>(markedAt),
    };
  }

  DoseEvent copyWith({
    String? id,
    String? medicationId,
    DateTime? scheduledAt,
    String? status,
    DateTime? markedAt,
  }) => DoseEvent(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    markedAt: markedAt ?? this.markedAt,
  );
  DoseEvent copyWithCompanion(DoseEventsCompanion data) {
    return DoseEvent(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseEvent(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicationId, scheduledAt, status, markedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseEvent &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.markedAt == this.markedAt);
}

class DoseEventsCompanion extends UpdateCompanion<DoseEvent> {
  final Value<String> id;
  final Value<String> medicationId;
  final Value<DateTime> scheduledAt;
  final Value<String> status;
  final Value<DateTime> markedAt;
  final Value<int> rowid;
  const DoseEventsCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.markedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseEventsCompanion.insert({
    this.id = const Value.absent(),
    required String medicationId,
    required DateTime scheduledAt,
    required String status,
    this.markedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       scheduledAt = Value(scheduledAt),
       status = Value(status);
  static Insertable<DoseEvent> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<DateTime>? scheduledAt,
    Expression<String>? status,
    Expression<DateTime>? markedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (markedAt != null) 'marked_at': markedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? medicationId,
    Value<DateTime>? scheduledAt,
    Value<String>? status,
    Value<DateTime>? markedAt,
    Value<int>? rowid,
  }) {
    return DoseEventsCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseEventsCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImmunizationsTable extends Immunizations
    with TableInfo<$ImmunizationsTable, Immunization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImmunizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaccineCodeMeta = const VerificationMeta(
    'vaccineCode',
  );
  @override
  late final GeneratedColumn<String> vaccineCode = GeneratedColumn<String>(
    'vaccine_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseNumberMeta = const VerificationMeta(
    'doseNumber',
  );
  @override
  late final GeneratedColumn<int> doseNumber = GeneratedColumn<int>(
    'dose_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotNumberMeta = const VerificationMeta(
    'lotNumber',
  );
  @override
  late final GeneratedColumn<String> lotNumber = GeneratedColumn<String>(
    'lot_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    vaccineName,
    vaccineCode,
    date,
    doseNumber,
    lotNumber,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'immunizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Immunization> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('vaccine_code')) {
      context.handle(
        _vaccineCodeMeta,
        vaccineCode.isAcceptableOrUnknown(
          data['vaccine_code']!,
          _vaccineCodeMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('dose_number')) {
      context.handle(
        _doseNumberMeta,
        doseNumber.isAcceptableOrUnknown(data['dose_number']!, _doseNumberMeta),
      );
    }
    if (data.containsKey('lot_number')) {
      context.handle(
        _lotNumberMeta,
        lotNumber.isAcceptableOrUnknown(data['lot_number']!, _lotNumberMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Immunization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Immunization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      vaccineCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_code'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      doseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_number'],
      ),
      lotNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_number'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ImmunizationsTable createAlias(String alias) {
    return $ImmunizationsTable(attachedDatabase, alias);
  }
}

class Immunization extends DataClass implements Insertable<Immunization> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String vaccineName;
  final String? vaccineCode;
  final DateTime date;
  final int? doseNumber;
  final String? lotNumber;
  final String? note;
  const Immunization({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.vaccineName,
    this.vaccineCode,
    required this.date,
    this.doseNumber,
    this.lotNumber,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['vaccine_name'] = Variable<String>(vaccineName);
    if (!nullToAbsent || vaccineCode != null) {
      map['vaccine_code'] = Variable<String>(vaccineCode);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || doseNumber != null) {
      map['dose_number'] = Variable<int>(doseNumber);
    }
    if (!nullToAbsent || lotNumber != null) {
      map['lot_number'] = Variable<String>(lotNumber);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ImmunizationsCompanion toCompanion(bool nullToAbsent) {
    return ImmunizationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      vaccineName: Value(vaccineName),
      vaccineCode: vaccineCode == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineCode),
      date: Value(date),
      doseNumber: doseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(doseNumber),
      lotNumber: lotNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(lotNumber),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Immunization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Immunization(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      vaccineCode: serializer.fromJson<String?>(json['vaccineCode']),
      date: serializer.fromJson<DateTime>(json['date']),
      doseNumber: serializer.fromJson<int?>(json['doseNumber']),
      lotNumber: serializer.fromJson<String?>(json['lotNumber']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'vaccineCode': serializer.toJson<String?>(vaccineCode),
      'date': serializer.toJson<DateTime>(date),
      'doseNumber': serializer.toJson<int?>(doseNumber),
      'lotNumber': serializer.toJson<String?>(lotNumber),
      'note': serializer.toJson<String?>(note),
    };
  }

  Immunization copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? vaccineName,
    Value<String?> vaccineCode = const Value.absent(),
    DateTime? date,
    Value<int?> doseNumber = const Value.absent(),
    Value<String?> lotNumber = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Immunization(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    vaccineName: vaccineName ?? this.vaccineName,
    vaccineCode: vaccineCode.present ? vaccineCode.value : this.vaccineCode,
    date: date ?? this.date,
    doseNumber: doseNumber.present ? doseNumber.value : this.doseNumber,
    lotNumber: lotNumber.present ? lotNumber.value : this.lotNumber,
    note: note.present ? note.value : this.note,
  );
  Immunization copyWithCompanion(ImmunizationsCompanion data) {
    return Immunization(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      vaccineCode: data.vaccineCode.present
          ? data.vaccineCode.value
          : this.vaccineCode,
      date: data.date.present ? data.date.value : this.date,
      doseNumber: data.doseNumber.present
          ? data.doseNumber.value
          : this.doseNumber,
      lotNumber: data.lotNumber.present ? data.lotNumber.value : this.lotNumber,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Immunization(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('date: $date, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    vaccineName,
    vaccineCode,
    date,
    doseNumber,
    lotNumber,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Immunization &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.vaccineName == this.vaccineName &&
          other.vaccineCode == this.vaccineCode &&
          other.date == this.date &&
          other.doseNumber == this.doseNumber &&
          other.lotNumber == this.lotNumber &&
          other.note == this.note);
}

class ImmunizationsCompanion extends UpdateCompanion<Immunization> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> vaccineName;
  final Value<String?> vaccineCode;
  final Value<DateTime> date;
  final Value<int?> doseNumber;
  final Value<String?> lotNumber;
  final Value<String?> note;
  final Value<int> rowid;
  const ImmunizationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.vaccineCode = const Value.absent(),
    this.date = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.lotNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImmunizationsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String vaccineName,
    this.vaccineCode = const Value.absent(),
    required DateTime date,
    this.doseNumber = const Value.absent(),
    this.lotNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       vaccineName = Value(vaccineName),
       date = Value(date);
  static Insertable<Immunization> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? vaccineName,
    Expression<String>? vaccineCode,
    Expression<DateTime>? date,
    Expression<int>? doseNumber,
    Expression<String>? lotNumber,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (vaccineCode != null) 'vaccine_code': vaccineCode,
      if (date != null) 'date': date,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (lotNumber != null) 'lot_number': lotNumber,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImmunizationsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? vaccineName,
    Value<String?>? vaccineCode,
    Value<DateTime>? date,
    Value<int?>? doseNumber,
    Value<String?>? lotNumber,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ImmunizationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccineCode: vaccineCode ?? this.vaccineCode,
      date: date ?? this.date,
      doseNumber: doseNumber ?? this.doseNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (vaccineCode.present) {
      map['vaccine_code'] = Variable<String>(vaccineCode.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (doseNumber.present) {
      map['dose_number'] = Variable<int>(doseNumber.value);
    }
    if (lotNumber.present) {
      map['lot_number'] = Variable<String>(lotNumber.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImmunizationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('date: $date, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImmunizationDueTable extends ImmunizationDue
    with TableInfo<$ImmunizationDueTable, DueVaccine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImmunizationDueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaccineCodeMeta = const VerificationMeta(
    'vaccineCode',
  );
  @override
  late final GeneratedColumn<String> vaccineCode = GeneratedColumn<String>(
    'vaccine_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseNumberMeta = const VerificationMeta(
    'doseNumber',
  );
  @override
  late final GeneratedColumn<int> doseNumber = GeneratedColumn<int>(
    'dose_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    vaccineName,
    vaccineCode,
    dueDate,
    doseNumber,
    note,
    done,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'immunization_due';
  @override
  VerificationContext validateIntegrity(
    Insertable<DueVaccine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('vaccine_code')) {
      context.handle(
        _vaccineCodeMeta,
        vaccineCode.isAcceptableOrUnknown(
          data['vaccine_code']!,
          _vaccineCodeMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('dose_number')) {
      context.handle(
        _doseNumberMeta,
        doseNumber.isAcceptableOrUnknown(data['dose_number']!, _doseNumberMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DueVaccine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DueVaccine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      vaccineCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_code'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      doseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_number'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
    );
  }

  @override
  $ImmunizationDueTable createAlias(String alias) {
    return $ImmunizationDueTable(attachedDatabase, alias);
  }
}

class DueVaccine extends DataClass implements Insertable<DueVaccine> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String vaccineName;
  final String? vaccineCode;
  final DateTime dueDate;
  final int? doseNumber;
  final String? note;
  final bool done;
  const DueVaccine({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.vaccineName,
    this.vaccineCode,
    required this.dueDate,
    this.doseNumber,
    this.note,
    required this.done,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['vaccine_name'] = Variable<String>(vaccineName);
    if (!nullToAbsent || vaccineCode != null) {
      map['vaccine_code'] = Variable<String>(vaccineCode);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || doseNumber != null) {
      map['dose_number'] = Variable<int>(doseNumber);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['done'] = Variable<bool>(done);
    return map;
  }

  ImmunizationDueCompanion toCompanion(bool nullToAbsent) {
    return ImmunizationDueCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      vaccineName: Value(vaccineName),
      vaccineCode: vaccineCode == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineCode),
      dueDate: Value(dueDate),
      doseNumber: doseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(doseNumber),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      done: Value(done),
    );
  }

  factory DueVaccine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DueVaccine(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      vaccineCode: serializer.fromJson<String?>(json['vaccineCode']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      doseNumber: serializer.fromJson<int?>(json['doseNumber']),
      note: serializer.fromJson<String?>(json['note']),
      done: serializer.fromJson<bool>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'vaccineCode': serializer.toJson<String?>(vaccineCode),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'doseNumber': serializer.toJson<int?>(doseNumber),
      'note': serializer.toJson<String?>(note),
      'done': serializer.toJson<bool>(done),
    };
  }

  DueVaccine copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? vaccineName,
    Value<String?> vaccineCode = const Value.absent(),
    DateTime? dueDate,
    Value<int?> doseNumber = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? done,
  }) => DueVaccine(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    vaccineName: vaccineName ?? this.vaccineName,
    vaccineCode: vaccineCode.present ? vaccineCode.value : this.vaccineCode,
    dueDate: dueDate ?? this.dueDate,
    doseNumber: doseNumber.present ? doseNumber.value : this.doseNumber,
    note: note.present ? note.value : this.note,
    done: done ?? this.done,
  );
  DueVaccine copyWithCompanion(ImmunizationDueCompanion data) {
    return DueVaccine(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      vaccineCode: data.vaccineCode.present
          ? data.vaccineCode.value
          : this.vaccineCode,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      doseNumber: data.doseNumber.present
          ? data.doseNumber.value
          : this.doseNumber,
      note: data.note.present ? data.note.value : this.note,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DueVaccine(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('dueDate: $dueDate, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('note: $note, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    vaccineName,
    vaccineCode,
    dueDate,
    doseNumber,
    note,
    done,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DueVaccine &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.vaccineName == this.vaccineName &&
          other.vaccineCode == this.vaccineCode &&
          other.dueDate == this.dueDate &&
          other.doseNumber == this.doseNumber &&
          other.note == this.note &&
          other.done == this.done);
}

class ImmunizationDueCompanion extends UpdateCompanion<DueVaccine> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> vaccineName;
  final Value<String?> vaccineCode;
  final Value<DateTime> dueDate;
  final Value<int?> doseNumber;
  final Value<String?> note;
  final Value<bool> done;
  final Value<int> rowid;
  const ImmunizationDueCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.vaccineCode = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImmunizationDueCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String vaccineName,
    this.vaccineCode = const Value.absent(),
    required DateTime dueDate,
    this.doseNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       vaccineName = Value(vaccineName),
       dueDate = Value(dueDate);
  static Insertable<DueVaccine> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? vaccineName,
    Expression<String>? vaccineCode,
    Expression<DateTime>? dueDate,
    Expression<int>? doseNumber,
    Expression<String>? note,
    Expression<bool>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (vaccineCode != null) 'vaccine_code': vaccineCode,
      if (dueDate != null) 'due_date': dueDate,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (note != null) 'note': note,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImmunizationDueCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? vaccineName,
    Value<String?>? vaccineCode,
    Value<DateTime>? dueDate,
    Value<int?>? doseNumber,
    Value<String?>? note,
    Value<bool>? done,
    Value<int>? rowid,
  }) {
    return ImmunizationDueCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccineCode: vaccineCode ?? this.vaccineCode,
      dueDate: dueDate ?? this.dueDate,
      doseNumber: doseNumber ?? this.doseNumber,
      note: note ?? this.note,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (vaccineCode.present) {
      map['vaccine_code'] = Variable<String>(vaccineCode.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (doseNumber.present) {
      map['dose_number'] = Variable<int>(doseNumber.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImmunizationDueCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('dueDate: $dueDate, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('note: $note, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _value2Meta = const VerificationMeta('value2');
  @override
  late final GeneratedColumn<double> value2 = GeneratedColumn<double>(
    'value2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveAt = GeneratedColumn<DateTime>(
    'effective_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    typeKey,
    code,
    name,
    value,
    value2,
    unit,
    effectiveAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('value2')) {
      context.handle(
        _value2Meta,
        value2.isAcceptableOrUnknown(data['value2']!, _value2Meta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      value2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value2'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;

  /// Uygulamanın ölçüm türü anahtarı (`bp`, `weight`…) ya da `other`.
  final String typeKey;
  final String? code;
  final String name;
  final double? value;

  /// Tansiyonda küçük (diyastolik) değer.
  final double? value2;
  final String unit;
  final DateTime effectiveAt;
  final String? note;
  const Observation({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.typeKey,
    this.code,
    required this.name,
    this.value,
    this.value2,
    required this.unit,
    required this.effectiveAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['type_key'] = Variable<String>(typeKey);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    if (!nullToAbsent || value2 != null) {
      map['value2'] = Variable<double>(value2);
    }
    map['unit'] = Variable<String>(unit);
    map['effective_at'] = Variable<DateTime>(effectiveAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      typeKey: Value(typeKey),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      value2: value2 == null && nullToAbsent
          ? const Value.absent()
          : Value(value2),
      unit: Value(unit),
      effectiveAt: Value(effectiveAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<double?>(json['value']),
      value2: serializer.fromJson<double?>(json['value2']),
      unit: serializer.fromJson<String>(json['unit']),
      effectiveAt: serializer.fromJson<DateTime>(json['effectiveAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'typeKey': serializer.toJson<String>(typeKey),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<double?>(value),
      'value2': serializer.toJson<double?>(value2),
      'unit': serializer.toJson<String>(unit),
      'effectiveAt': serializer.toJson<DateTime>(effectiveAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  Observation copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? typeKey,
    Value<String?> code = const Value.absent(),
    String? name,
    Value<double?> value = const Value.absent(),
    Value<double?> value2 = const Value.absent(),
    String? unit,
    DateTime? effectiveAt,
    Value<String?> note = const Value.absent(),
  }) => Observation(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    typeKey: typeKey ?? this.typeKey,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    value: value.present ? value.value : this.value,
    value2: value2.present ? value2.value : this.value2,
    unit: unit ?? this.unit,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    note: note.present ? note.value : this.note,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      value2: data.value2.present ? data.value2.value : this.value2,
      unit: data.unit.present ? data.unit.value : this.unit,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('typeKey: $typeKey, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    typeKey,
    code,
    name,
    value,
    value2,
    unit,
    effectiveAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.typeKey == this.typeKey &&
          other.code == this.code &&
          other.name == this.name &&
          other.value == this.value &&
          other.value2 == this.value2 &&
          other.unit == this.unit &&
          other.effectiveAt == this.effectiveAt &&
          other.note == this.note);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> typeKey;
  final Value<String?> code;
  final Value<String> name;
  final Value<double?> value;
  final Value<double?> value2;
  final Value<String> unit;
  final Value<DateTime> effectiveAt;
  final Value<String?> note;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.value2 = const Value.absent(),
    this.unit = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String typeKey,
    this.code = const Value.absent(),
    required String name,
    this.value = const Value.absent(),
    this.value2 = const Value.absent(),
    this.unit = const Value.absent(),
    required DateTime effectiveAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       typeKey = Value(typeKey),
       name = Value(name),
       effectiveAt = Value(effectiveAt);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? typeKey,
    Expression<String>? code,
    Expression<String>? name,
    Expression<double>? value,
    Expression<double>? value2,
    Expression<String>? unit,
    Expression<DateTime>? effectiveAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (typeKey != null) 'type_key': typeKey,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (value2 != null) 'value2': value2,
      if (unit != null) 'unit': unit,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? typeKey,
    Value<String?>? code,
    Value<String>? name,
    Value<double?>? value,
    Value<double?>? value2,
    Value<String>? unit,
    Value<DateTime>? effectiveAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      typeKey: typeKey ?? this.typeKey,
      code: code ?? this.code,
      name: name ?? this.name,
      value: value ?? this.value,
      value2: value2 ?? this.value2,
      unit: unit ?? this.unit,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (value2.present) {
      map['value2'] = Variable<double>(value2.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<DateTime>(effectiveAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('typeKey: $typeKey, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('value2: $value2, ')
          ..write('unit: $unit, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('note: $note, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _practitionerMeta = const VerificationMeta(
    'practitioner',
  );
  @override
  late final GeneratedColumn<String> practitioner = GeneratedColumn<String>(
    'practitioner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    start,
    title,
    practitioner,
    location,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('practitioner')) {
      context.handle(
        _practitionerMeta,
        practitioner.isAcceptableOrUnknown(
          data['practitioner']!,
          _practitionerMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      practitioner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practitioner'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final DateTime start;
  final String title;
  final String? practitioner;
  final String? location;
  final String? note;
  const Appointment({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.start,
    required this.title,
    this.practitioner,
    this.location,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['start'] = Variable<DateTime>(start);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || practitioner != null) {
      map['practitioner'] = Variable<String>(practitioner);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      start: Value(start),
      title: Value(title),
      practitioner: practitioner == null && nullToAbsent
          ? const Value.absent()
          : Value(practitioner),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      start: serializer.fromJson<DateTime>(json['start']),
      title: serializer.fromJson<String>(json['title']),
      practitioner: serializer.fromJson<String?>(json['practitioner']),
      location: serializer.fromJson<String?>(json['location']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'start': serializer.toJson<DateTime>(start),
      'title': serializer.toJson<String>(title),
      'practitioner': serializer.toJson<String?>(practitioner),
      'location': serializer.toJson<String?>(location),
      'note': serializer.toJson<String?>(note),
    };
  }

  Appointment copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? start,
    String? title,
    Value<String?> practitioner = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Appointment(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    start: start ?? this.start,
    title: title ?? this.title,
    practitioner: practitioner.present ? practitioner.value : this.practitioner,
    location: location.present ? location.value : this.location,
    note: note.present ? note.value : this.note,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      start: data.start.present ? data.start.value : this.start,
      title: data.title.present ? data.title.value : this.title,
      practitioner: data.practitioner.present
          ? data.practitioner.value
          : this.practitioner,
      location: data.location.present ? data.location.value : this.location,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('start: $start, ')
          ..write('title: $title, ')
          ..write('practitioner: $practitioner, ')
          ..write('location: $location, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    start,
    title,
    practitioner,
    location,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.start == this.start &&
          other.title == this.title &&
          other.practitioner == this.practitioner &&
          other.location == this.location &&
          other.note == this.note);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> start;
  final Value<String> title;
  final Value<String?> practitioner;
  final Value<String?> location;
  final Value<String?> note;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.start = const Value.absent(),
    this.title = const Value.absent(),
    this.practitioner = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime start,
    this.title = const Value.absent(),
    this.practitioner = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       start = Value(start);
  static Insertable<Appointment> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? start,
    Expression<String>? title,
    Expression<String>? practitioner,
    Expression<String>? location,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (start != null) 'start': start,
      if (title != null) 'title': title,
      if (practitioner != null) 'practitioner': practitioner,
      if (location != null) 'location': location,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? start,
    Value<String>? title,
    Value<String?>? practitioner,
    Value<String?>? location,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      start: start ?? this.start,
      title: title ?? this.title,
      practitioner: practitioner ?? this.practitioner,
      location: location ?? this.location,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (practitioner.present) {
      map['practitioner'] = Variable<String>(practitioner.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('start: $start, ')
          ..write('title: $title, ')
          ..write('practitioner: $practitioner, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllergiesTable extends Allergies
    with TableInfo<$AllergiesTable, Allergy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllergiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _substanceMeta = const VerificationMeta(
    'substance',
  );
  @override
  late final GeneratedColumn<String> substance = GeneratedColumn<String>(
    'substance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactionMeta = const VerificationMeta(
    'reaction',
  );
  @override
  late final GeneratedColumn<String> reaction = GeneratedColumn<String>(
    'reaction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criticalityMeta = const VerificationMeta(
    'criticality',
  );
  @override
  late final GeneratedColumn<String> criticality = GeneratedColumn<String>(
    'criticality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    substance,
    code,
    reaction,
    criticality,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allergies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Allergy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('substance')) {
      context.handle(
        _substanceMeta,
        substance.isAcceptableOrUnknown(data['substance']!, _substanceMeta),
      );
    } else if (isInserting) {
      context.missing(_substanceMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('reaction')) {
      context.handle(
        _reactionMeta,
        reaction.isAcceptableOrUnknown(data['reaction']!, _reactionMeta),
      );
    }
    if (data.containsKey('criticality')) {
      context.handle(
        _criticalityMeta,
        criticality.isAcceptableOrUnknown(
          data['criticality']!,
          _criticalityMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Allergy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Allergy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      substance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substance'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      reaction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction'],
      ),
      criticality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criticality'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AllergiesTable createAlias(String alias) {
    return $AllergiesTable(attachedDatabase, alias);
  }
}

class Allergy extends DataClass implements Insertable<Allergy> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String substance;
  final String? code;
  final String? reaction;

  /// `high` (ağır) ya da `low` (hafif); boş olabilir.
  final String? criticality;
  final String? note;
  const Allergy({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.substance,
    this.code,
    this.reaction,
    this.criticality,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['substance'] = Variable<String>(substance);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || reaction != null) {
      map['reaction'] = Variable<String>(reaction);
    }
    if (!nullToAbsent || criticality != null) {
      map['criticality'] = Variable<String>(criticality);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AllergiesCompanion toCompanion(bool nullToAbsent) {
    return AllergiesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      substance: Value(substance),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      reaction: reaction == null && nullToAbsent
          ? const Value.absent()
          : Value(reaction),
      criticality: criticality == null && nullToAbsent
          ? const Value.absent()
          : Value(criticality),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Allergy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Allergy(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      substance: serializer.fromJson<String>(json['substance']),
      code: serializer.fromJson<String?>(json['code']),
      reaction: serializer.fromJson<String?>(json['reaction']),
      criticality: serializer.fromJson<String?>(json['criticality']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'substance': serializer.toJson<String>(substance),
      'code': serializer.toJson<String?>(code),
      'reaction': serializer.toJson<String?>(reaction),
      'criticality': serializer.toJson<String?>(criticality),
      'note': serializer.toJson<String?>(note),
    };
  }

  Allergy copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? substance,
    Value<String?> code = const Value.absent(),
    Value<String?> reaction = const Value.absent(),
    Value<String?> criticality = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Allergy(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    substance: substance ?? this.substance,
    code: code.present ? code.value : this.code,
    reaction: reaction.present ? reaction.value : this.reaction,
    criticality: criticality.present ? criticality.value : this.criticality,
    note: note.present ? note.value : this.note,
  );
  Allergy copyWithCompanion(AllergiesCompanion data) {
    return Allergy(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      substance: data.substance.present ? data.substance.value : this.substance,
      code: data.code.present ? data.code.value : this.code,
      reaction: data.reaction.present ? data.reaction.value : this.reaction,
      criticality: data.criticality.present
          ? data.criticality.value
          : this.criticality,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Allergy(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('substance: $substance, ')
          ..write('code: $code, ')
          ..write('reaction: $reaction, ')
          ..write('criticality: $criticality, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    substance,
    code,
    reaction,
    criticality,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Allergy &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.substance == this.substance &&
          other.code == this.code &&
          other.reaction == this.reaction &&
          other.criticality == this.criticality &&
          other.note == this.note);
}

class AllergiesCompanion extends UpdateCompanion<Allergy> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> substance;
  final Value<String?> code;
  final Value<String?> reaction;
  final Value<String?> criticality;
  final Value<String?> note;
  final Value<int> rowid;
  const AllergiesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.substance = const Value.absent(),
    this.code = const Value.absent(),
    this.reaction = const Value.absent(),
    this.criticality = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllergiesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String substance,
    this.code = const Value.absent(),
    this.reaction = const Value.absent(),
    this.criticality = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       substance = Value(substance);
  static Insertable<Allergy> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? substance,
    Expression<String>? code,
    Expression<String>? reaction,
    Expression<String>? criticality,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (substance != null) 'substance': substance,
      if (code != null) 'code': code,
      if (reaction != null) 'reaction': reaction,
      if (criticality != null) 'criticality': criticality,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllergiesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? substance,
    Value<String?>? code,
    Value<String?>? reaction,
    Value<String?>? criticality,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return AllergiesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      substance: substance ?? this.substance,
      code: code ?? this.code,
      reaction: reaction ?? this.reaction,
      criticality: criticality ?? this.criticality,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (substance.present) {
      map['substance'] = Variable<String>(substance.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (reaction.present) {
      map['reaction'] = Variable<String>(reaction.value);
    }
    if (criticality.present) {
      map['criticality'] = Variable<String>(criticality.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('substance: $substance, ')
          ..write('code: $code, ')
          ..write('reaction: $reaction, ')
          ..write('criticality: $criticality, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConditionsTable extends Conditions
    with TableInfo<$ConditionsTable, Condition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordSource.self),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeSystemMeta = const VerificationMeta(
    'codeSystem',
  );
  @override
  late final GeneratedColumn<String> codeSystem = GeneratedColumn<String>(
    'code_system',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onsetDateMeta = const VerificationMeta(
    'onsetDate',
  );
  @override
  late final GeneratedColumn<DateTime> onsetDate = GeneratedColumn<DateTime>(
    'onset_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(ConditionStatus.active),
  );
  static const VerificationMeta _resolvedDateMeta = const VerificationMeta(
    'resolvedDate',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedDate = GeneratedColumn<DateTime>(
    'resolved_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    name,
    code,
    codeSystem,
    onsetDate,
    status,
    resolvedDate,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Condition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('code_system')) {
      context.handle(
        _codeSystemMeta,
        codeSystem.isAcceptableOrUnknown(data['code_system']!, _codeSystemMeta),
      );
    }
    if (data.containsKey('onset_date')) {
      context.handle(
        _onsetDateMeta,
        onsetDate.isAcceptableOrUnknown(data['onset_date']!, _onsetDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('resolved_date')) {
      context.handle(
        _resolvedDateMeta,
        resolvedDate.isAcceptableOrUnknown(
          data['resolved_date']!,
          _resolvedDateMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Condition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Condition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      codeSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_system'],
      ),
      onsetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onset_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resolvedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ConditionsTable createAlias(String alias) {
    return $ConditionsTable(attachedDatabase, alias);
  }
}

class Condition extends DataClass implements Insertable<Condition> {
  final String id;
  final String profileId;
  final String source;

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  final String? originName;

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  final String? originRef;
  final DateTime createdAt;
  final String name;
  final String? code;

  /// [code]'un kod sistemi; bkz. [Diagnoses.codeSystem].
  final String? codeSystem;
  final DateTime? onsetDate;

  /// [ConditionStatus] değerlerinden biri.
  final String status;

  /// Hastalığın geçtiği tarih (yalnızca geçirilmiş hastalıklarda).
  final DateTime? resolvedDate;
  final String? note;
  const Condition({
    required this.id,
    required this.profileId,
    required this.source,
    this.originName,
    this.originRef,
    required this.createdAt,
    required this.name,
    this.code,
    this.codeSystem,
    this.onsetDate,
    required this.status,
    this.resolvedDate,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || codeSystem != null) {
      map['code_system'] = Variable<String>(codeSystem);
    }
    if (!nullToAbsent || onsetDate != null) {
      map['onset_date'] = Variable<DateTime>(onsetDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resolvedDate != null) {
      map['resolved_date'] = Variable<DateTime>(resolvedDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ConditionsCompanion toCompanion(bool nullToAbsent) {
    return ConditionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      source: Value(source),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
      createdAt: Value(createdAt),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      codeSystem: codeSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(codeSystem),
      onsetDate: onsetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(onsetDate),
      status: Value(status),
      resolvedDate: resolvedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Condition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Condition(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      originName: serializer.fromJson<String?>(json['originName']),
      originRef: serializer.fromJson<String?>(json['originRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      codeSystem: serializer.fromJson<String?>(json['codeSystem']),
      onsetDate: serializer.fromJson<DateTime?>(json['onsetDate']),
      status: serializer.fromJson<String>(json['status']),
      resolvedDate: serializer.fromJson<DateTime?>(json['resolvedDate']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'source': serializer.toJson<String>(source),
      'originName': serializer.toJson<String?>(originName),
      'originRef': serializer.toJson<String?>(originRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'codeSystem': serializer.toJson<String?>(codeSystem),
      'onsetDate': serializer.toJson<DateTime?>(onsetDate),
      'status': serializer.toJson<String>(status),
      'resolvedDate': serializer.toJson<DateTime?>(resolvedDate),
      'note': serializer.toJson<String?>(note),
    };
  }

  Condition copyWith({
    String? id,
    String? profileId,
    String? source,
    Value<String?> originName = const Value.absent(),
    Value<String?> originRef = const Value.absent(),
    DateTime? createdAt,
    String? name,
    Value<String?> code = const Value.absent(),
    Value<String?> codeSystem = const Value.absent(),
    Value<DateTime?> onsetDate = const Value.absent(),
    String? status,
    Value<DateTime?> resolvedDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Condition(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    source: source ?? this.source,
    originName: originName.present ? originName.value : this.originName,
    originRef: originRef.present ? originRef.value : this.originRef,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    codeSystem: codeSystem.present ? codeSystem.value : this.codeSystem,
    onsetDate: onsetDate.present ? onsetDate.value : this.onsetDate,
    status: status ?? this.status,
    resolvedDate: resolvedDate.present ? resolvedDate.value : this.resolvedDate,
    note: note.present ? note.value : this.note,
  );
  Condition copyWithCompanion(ConditionsCompanion data) {
    return Condition(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      codeSystem: data.codeSystem.present
          ? data.codeSystem.value
          : this.codeSystem,
      onsetDate: data.onsetDate.present ? data.onsetDate.value : this.onsetDate,
      status: data.status.present ? data.status.value : this.status,
      resolvedDate: data.resolvedDate.present
          ? data.resolvedDate.value
          : this.resolvedDate,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Condition(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('codeSystem: $codeSystem, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('status: $status, ')
          ..write('resolvedDate: $resolvedDate, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    source,
    originName,
    originRef,
    createdAt,
    name,
    code,
    codeSystem,
    onsetDate,
    status,
    resolvedDate,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Condition &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.originName == this.originName &&
          other.originRef == this.originRef &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.code == this.code &&
          other.codeSystem == this.codeSystem &&
          other.onsetDate == this.onsetDate &&
          other.status == this.status &&
          other.resolvedDate == this.resolvedDate &&
          other.note == this.note);
}

class ConditionsCompanion extends UpdateCompanion<Condition> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> source;
  final Value<String?> originName;
  final Value<String?> originRef;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<String?> code;
  final Value<String?> codeSystem;
  final Value<DateTime?> onsetDate;
  final Value<String> status;
  final Value<DateTime?> resolvedDate;
  final Value<String?> note;
  final Value<int> rowid;
  const ConditionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.codeSystem = const Value.absent(),
    this.onsetDate = const Value.absent(),
    this.status = const Value.absent(),
    this.resolvedDate = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConditionsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.source = const Value.absent(),
    this.originName = const Value.absent(),
    this.originRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String name,
    this.code = const Value.absent(),
    this.codeSystem = const Value.absent(),
    this.onsetDate = const Value.absent(),
    this.status = const Value.absent(),
    this.resolvedDate = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name);
  static Insertable<Condition> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<String>? originName,
    Expression<String>? originRef,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? codeSystem,
    Expression<DateTime>? onsetDate,
    Expression<String>? status,
    Expression<DateTime>? resolvedDate,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (originName != null) 'origin_name': originName,
      if (originRef != null) 'origin_ref': originRef,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (codeSystem != null) 'code_system': codeSystem,
      if (onsetDate != null) 'onset_date': onsetDate,
      if (status != null) 'status': status,
      if (resolvedDate != null) 'resolved_date': resolvedDate,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConditionsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? source,
    Value<String?>? originName,
    Value<String?>? originRef,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<String?>? code,
    Value<String?>? codeSystem,
    Value<DateTime?>? onsetDate,
    Value<String>? status,
    Value<DateTime?>? resolvedDate,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ConditionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      originName: originName ?? this.originName,
      originRef: originRef ?? this.originRef,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      code: code ?? this.code,
      codeSystem: codeSystem ?? this.codeSystem,
      onsetDate: onsetDate ?? this.onsetDate,
      status: status ?? this.status,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (codeSystem.present) {
      map['code_system'] = Variable<String>(codeSystem.value);
    }
    if (onsetDate.present) {
      map['onset_date'] = Variable<DateTime>(onsetDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resolvedDate.present) {
      map['resolved_date'] = Variable<DateTime>(resolvedDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConditionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('originName: $originName, ')
          ..write('originRef: $originRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('codeSystem: $codeSystem, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('status: $status, ')
          ..write('resolvedDate: $resolvedDate, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FhirResourcesTable extends FhirResources
    with TableInfo<$FhirResourcesTable, FhirResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FhirResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resourceType,
    localId,
    profileId,
    json,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fhir_resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<FhirResource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceType, localId};
  @override
  FhirResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FhirResource(
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $FhirResourcesTable createAlias(String alias) {
    return $FhirResourcesTable(attachedDatabase, alias);
  }
}

class FhirResource extends DataClass implements Insertable<FhirResource> {
  final String resourceType;

  /// İlgili tablodaki satır kimliği.
  final String localId;
  final String profileId;
  final String json;
  final DateTime lastUpdated;
  const FhirResource({
    required this.resourceType,
    required this.localId,
    required this.profileId,
    required this.json,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_type'] = Variable<String>(resourceType);
    map['local_id'] = Variable<String>(localId);
    map['profile_id'] = Variable<String>(profileId);
    map['json'] = Variable<String>(json);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  FhirResourcesCompanion toCompanion(bool nullToAbsent) {
    return FhirResourcesCompanion(
      resourceType: Value(resourceType),
      localId: Value(localId),
      profileId: Value(profileId),
      json: Value(json),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory FhirResource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FhirResource(
      resourceType: serializer.fromJson<String>(json['resourceType']),
      localId: serializer.fromJson<String>(json['localId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      json: serializer.fromJson<String>(json['json']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceType': serializer.toJson<String>(resourceType),
      'localId': serializer.toJson<String>(localId),
      'profileId': serializer.toJson<String>(profileId),
      'json': serializer.toJson<String>(json),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  FhirResource copyWith({
    String? resourceType,
    String? localId,
    String? profileId,
    String? json,
    DateTime? lastUpdated,
  }) => FhirResource(
    resourceType: resourceType ?? this.resourceType,
    localId: localId ?? this.localId,
    profileId: profileId ?? this.profileId,
    json: json ?? this.json,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  FhirResource copyWithCompanion(FhirResourcesCompanion data) {
    return FhirResource(
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      localId: data.localId.present ? data.localId.value : this.localId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      json: data.json.present ? data.json.value : this.json,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FhirResource(')
          ..write('resourceType: $resourceType, ')
          ..write('localId: $localId, ')
          ..write('profileId: $profileId, ')
          ..write('json: $json, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(resourceType, localId, profileId, json, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FhirResource &&
          other.resourceType == this.resourceType &&
          other.localId == this.localId &&
          other.profileId == this.profileId &&
          other.json == this.json &&
          other.lastUpdated == this.lastUpdated);
}

class FhirResourcesCompanion extends UpdateCompanion<FhirResource> {
  final Value<String> resourceType;
  final Value<String> localId;
  final Value<String> profileId;
  final Value<String> json;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const FhirResourcesCompanion({
    this.resourceType = const Value.absent(),
    this.localId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.json = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FhirResourcesCompanion.insert({
    required String resourceType,
    required String localId,
    required String profileId,
    required String json,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resourceType = Value(resourceType),
       localId = Value(localId),
       profileId = Value(profileId),
       json = Value(json);
  static Insertable<FhirResource> custom({
    Expression<String>? resourceType,
    Expression<String>? localId,
    Expression<String>? profileId,
    Expression<String>? json,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceType != null) 'resource_type': resourceType,
      if (localId != null) 'local_id': localId,
      if (profileId != null) 'profile_id': profileId,
      if (json != null) 'json': json,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FhirResourcesCompanion copyWith({
    Value<String>? resourceType,
    Value<String>? localId,
    Value<String>? profileId,
    Value<String>? json,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return FhirResourcesCompanion(
      resourceType: resourceType ?? this.resourceType,
      localId: localId ?? this.localId,
      profileId: profileId ?? this.profileId,
      json: json ?? this.json,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FhirResourcesCompanion(')
          ..write('resourceType: $resourceType, ')
          ..write('localId: $localId, ')
          ..write('profileId: $profileId, ')
          ..write('json: $json, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportHistoryTable extends ImportHistory
    with TableInfo<$ImportHistoryTable, ImportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importedAt,
    profileId,
    originName,
    summary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
    );
  }

  @override
  $ImportHistoryTable createAlias(String alias) {
    return $ImportHistoryTable(attachedDatabase, alias);
  }
}

class ImportRecord extends DataClass implements Insertable<ImportRecord> {
  final String id;
  final DateTime importedAt;
  final String profileId;
  final String? originName;
  final String summary;
  const ImportRecord({
    required this.id,
    required this.importedAt,
    required this.profileId,
    this.originName,
    required this.summary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || originName != null) {
      map['origin_name'] = Variable<String>(originName);
    }
    map['summary'] = Variable<String>(summary);
    return map;
  }

  ImportHistoryCompanion toCompanion(bool nullToAbsent) {
    return ImportHistoryCompanion(
      id: Value(id),
      importedAt: Value(importedAt),
      profileId: Value(profileId),
      originName: originName == null && nullToAbsent
          ? const Value.absent()
          : Value(originName),
      summary: Value(summary),
    );
  }

  factory ImportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportRecord(
      id: serializer.fromJson<String>(json['id']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      profileId: serializer.fromJson<String>(json['profileId']),
      originName: serializer.fromJson<String?>(json['originName']),
      summary: serializer.fromJson<String>(json['summary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'profileId': serializer.toJson<String>(profileId),
      'originName': serializer.toJson<String?>(originName),
      'summary': serializer.toJson<String>(summary),
    };
  }

  ImportRecord copyWith({
    String? id,
    DateTime? importedAt,
    String? profileId,
    Value<String?> originName = const Value.absent(),
    String? summary,
  }) => ImportRecord(
    id: id ?? this.id,
    importedAt: importedAt ?? this.importedAt,
    profileId: profileId ?? this.profileId,
    originName: originName.present ? originName.value : this.originName,
    summary: summary ?? this.summary,
  );
  ImportRecord copyWithCompanion(ImportHistoryCompanion data) {
    return ImportRecord(
      id: data.id.present ? data.id.value : this.id,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      summary: data.summary.present ? data.summary.value : this.summary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportRecord(')
          ..write('id: $id, ')
          ..write('importedAt: $importedAt, ')
          ..write('profileId: $profileId, ')
          ..write('originName: $originName, ')
          ..write('summary: $summary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, importedAt, profileId, originName, summary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportRecord &&
          other.id == this.id &&
          other.importedAt == this.importedAt &&
          other.profileId == this.profileId &&
          other.originName == this.originName &&
          other.summary == this.summary);
}

class ImportHistoryCompanion extends UpdateCompanion<ImportRecord> {
  final Value<String> id;
  final Value<DateTime> importedAt;
  final Value<String> profileId;
  final Value<String?> originName;
  final Value<String> summary;
  final Value<int> rowid;
  const ImportHistoryCompanion({
    this.id = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.profileId = const Value.absent(),
    this.originName = const Value.absent(),
    this.summary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.importedAt = const Value.absent(),
    required String profileId,
    this.originName = const Value.absent(),
    required String summary,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       summary = Value(summary);
  static Insertable<ImportRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? importedAt,
    Expression<String>? profileId,
    Expression<String>? originName,
    Expression<String>? summary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importedAt != null) 'imported_at': importedAt,
      if (profileId != null) 'profile_id': profileId,
      if (originName != null) 'origin_name': originName,
      if (summary != null) 'summary': summary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportHistoryCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? importedAt,
    Value<String>? profileId,
    Value<String?>? originName,
    Value<String>? summary,
    Value<int>? rowid,
  }) {
    return ImportHistoryCompanion(
      id: id ?? this.id,
      importedAt: importedAt ?? this.importedAt,
      profileId: profileId ?? this.profileId,
      originName: originName ?? this.originName,
      summary: summary ?? this.summary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportHistoryCompanion(')
          ..write('id: $id, ')
          ..write('importedAt: $importedAt, ')
          ..write('profileId: $profileId, ')
          ..write('originName: $originName, ')
          ..write('summary: $summary, ')
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
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
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
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProfileLinksTable profileLinks = $ProfileLinksTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $DiagnosesTable diagnoses = $DiagnosesTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $DoseEventsTable doseEvents = $DoseEventsTable(this);
  late final $ImmunizationsTable immunizations = $ImmunizationsTable(this);
  late final $ImmunizationDueTable immunizationDue = $ImmunizationDueTable(
    this,
  );
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $AllergiesTable allergies = $AllergiesTable(this);
  late final $ConditionsTable conditions = $ConditionsTable(this);
  late final $FhirResourcesTable fhirResources = $FhirResourcesTable(this);
  late final $ImportHistoryTable importHistory = $ImportHistoryTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    profileLinks,
    encounters,
    diagnoses,
    medications,
    doseEvents,
    immunizations,
    immunizationDue,
    observations,
    appointments,
    allergies,
    conditions,
    fhirResources,
    importHistory,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('profile_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('encounters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('diagnoses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medications', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dose_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('immunizations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('immunization_due', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('observations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('appointments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('allergies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conditions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fhir_resources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_history', kind: UpdateKind.delete)],
    ),
  ]);
}
