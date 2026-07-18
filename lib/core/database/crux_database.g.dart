// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crux_database.dart';

// ignore_for_file: type=lint
class $UserRouteFlagsTable extends UserRouteFlags
    with TableInfo<$UserRouteFlagsTable, UserRouteFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRouteFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isProjectMeta = const VerificationMeta(
    'isProject',
  );
  @override
  late final GeneratedColumn<bool> isProject = GeneratedColumn<bool>(
    'is_project',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_project" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [routeId, isFavorite, isProject];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_route_flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRouteFlag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_project')) {
      context.handle(
        _isProjectMeta,
        isProject.isAcceptableOrUnknown(data['is_project']!, _isProjectMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routeId};
  @override
  UserRouteFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRouteFlag(
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isProject: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_project'],
      )!,
    );
  }

  @override
  $UserRouteFlagsTable createAlias(String alias) {
    return $UserRouteFlagsTable(attachedDatabase, alias);
  }
}

class UserRouteFlag extends DataClass implements Insertable<UserRouteFlag> {
  final String routeId;
  final bool isFavorite;
  final bool isProject;
  const UserRouteFlag({
    required this.routeId,
    required this.isFavorite,
    required this.isProject,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['route_id'] = Variable<String>(routeId);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_project'] = Variable<bool>(isProject);
    return map;
  }

  UserRouteFlagsCompanion toCompanion(bool nullToAbsent) {
    return UserRouteFlagsCompanion(
      routeId: Value(routeId),
      isFavorite: Value(isFavorite),
      isProject: Value(isProject),
    );
  }

  factory UserRouteFlag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRouteFlag(
      routeId: serializer.fromJson<String>(json['routeId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isProject: serializer.fromJson<bool>(json['isProject']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routeId': serializer.toJson<String>(routeId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isProject': serializer.toJson<bool>(isProject),
    };
  }

  UserRouteFlag copyWith({
    String? routeId,
    bool? isFavorite,
    bool? isProject,
  }) => UserRouteFlag(
    routeId: routeId ?? this.routeId,
    isFavorite: isFavorite ?? this.isFavorite,
    isProject: isProject ?? this.isProject,
  );
  UserRouteFlag copyWithCompanion(UserRouteFlagsCompanion data) {
    return UserRouteFlag(
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isProject: data.isProject.present ? data.isProject.value : this.isProject,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRouteFlag(')
          ..write('routeId: $routeId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isProject: $isProject')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(routeId, isFavorite, isProject);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRouteFlag &&
          other.routeId == this.routeId &&
          other.isFavorite == this.isFavorite &&
          other.isProject == this.isProject);
}

class UserRouteFlagsCompanion extends UpdateCompanion<UserRouteFlag> {
  final Value<String> routeId;
  final Value<bool> isFavorite;
  final Value<bool> isProject;
  final Value<int> rowid;
  const UserRouteFlagsCompanion({
    this.routeId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isProject = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRouteFlagsCompanion.insert({
    required String routeId,
    this.isFavorite = const Value.absent(),
    this.isProject = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : routeId = Value(routeId);
  static Insertable<UserRouteFlag> custom({
    Expression<String>? routeId,
    Expression<bool>? isFavorite,
    Expression<bool>? isProject,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routeId != null) 'route_id': routeId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isProject != null) 'is_project': isProject,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRouteFlagsCompanion copyWith({
    Value<String>? routeId,
    Value<bool>? isFavorite,
    Value<bool>? isProject,
    Value<int>? rowid,
  }) {
    return UserRouteFlagsCompanion(
      routeId: routeId ?? this.routeId,
      isFavorite: isFavorite ?? this.isFavorite,
      isProject: isProject ?? this.isProject,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isProject.present) {
      map['is_project'] = Variable<bool>(isProject.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRouteFlagsCompanion(')
          ..write('routeId: $routeId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isProject: $isProject, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentAreaViewsTable extends RecentAreaViews
    with TableInfo<$RecentAreaViewsTable, RecentAreaView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentAreaViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewedAtMicrosMeta = const VerificationMeta(
    'viewedAtMicros',
  );
  @override
  late final GeneratedColumn<int> viewedAtMicros = GeneratedColumn<int>(
    'viewed_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [areaId, viewedAtMicros];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_area_views';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentAreaView> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('viewed_at_micros')) {
      context.handle(
        _viewedAtMicrosMeta,
        viewedAtMicros.isAcceptableOrUnknown(
          data['viewed_at_micros']!,
          _viewedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_viewedAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {areaId};
  @override
  RecentAreaView map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentAreaView(
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      )!,
      viewedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viewed_at_micros'],
      )!,
    );
  }

  @override
  $RecentAreaViewsTable createAlias(String alias) {
    return $RecentAreaViewsTable(attachedDatabase, alias);
  }
}

class RecentAreaView extends DataClass implements Insertable<RecentAreaView> {
  final String areaId;
  final int viewedAtMicros;
  const RecentAreaView({required this.areaId, required this.viewedAtMicros});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['area_id'] = Variable<String>(areaId);
    map['viewed_at_micros'] = Variable<int>(viewedAtMicros);
    return map;
  }

  RecentAreaViewsCompanion toCompanion(bool nullToAbsent) {
    return RecentAreaViewsCompanion(
      areaId: Value(areaId),
      viewedAtMicros: Value(viewedAtMicros),
    );
  }

  factory RecentAreaView.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentAreaView(
      areaId: serializer.fromJson<String>(json['areaId']),
      viewedAtMicros: serializer.fromJson<int>(json['viewedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'areaId': serializer.toJson<String>(areaId),
      'viewedAtMicros': serializer.toJson<int>(viewedAtMicros),
    };
  }

  RecentAreaView copyWith({String? areaId, int? viewedAtMicros}) =>
      RecentAreaView(
        areaId: areaId ?? this.areaId,
        viewedAtMicros: viewedAtMicros ?? this.viewedAtMicros,
      );
  RecentAreaView copyWithCompanion(RecentAreaViewsCompanion data) {
    return RecentAreaView(
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      viewedAtMicros: data.viewedAtMicros.present
          ? data.viewedAtMicros.value
          : this.viewedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentAreaView(')
          ..write('areaId: $areaId, ')
          ..write('viewedAtMicros: $viewedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(areaId, viewedAtMicros);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentAreaView &&
          other.areaId == this.areaId &&
          other.viewedAtMicros == this.viewedAtMicros);
}

class RecentAreaViewsCompanion extends UpdateCompanion<RecentAreaView> {
  final Value<String> areaId;
  final Value<int> viewedAtMicros;
  final Value<int> rowid;
  const RecentAreaViewsCompanion({
    this.areaId = const Value.absent(),
    this.viewedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentAreaViewsCompanion.insert({
    required String areaId,
    required int viewedAtMicros,
    this.rowid = const Value.absent(),
  }) : areaId = Value(areaId),
       viewedAtMicros = Value(viewedAtMicros);
  static Insertable<RecentAreaView> custom({
    Expression<String>? areaId,
    Expression<int>? viewedAtMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (areaId != null) 'area_id': areaId,
      if (viewedAtMicros != null) 'viewed_at_micros': viewedAtMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentAreaViewsCompanion copyWith({
    Value<String>? areaId,
    Value<int>? viewedAtMicros,
    Value<int>? rowid,
  }) {
    return RecentAreaViewsCompanion(
      areaId: areaId ?? this.areaId,
      viewedAtMicros: viewedAtMicros ?? this.viewedAtMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (viewedAtMicros.present) {
      map['viewed_at_micros'] = Variable<int>(viewedAtMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentAreaViewsCompanion(')
          ..write('areaId: $areaId, ')
          ..write('viewedAtMicros: $viewedAtMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogMetaTable extends CatalogMeta
    with TableInfo<$CatalogMetaTable, CatalogMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogMetaTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'catalog_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogMetaData> instance, {
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
  CatalogMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogMetaData(
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
  $CatalogMetaTable createAlias(String alias) {
    return $CatalogMetaTable(attachedDatabase, alias);
  }
}

class CatalogMetaData extends DataClass implements Insertable<CatalogMetaData> {
  final String key;
  final String value;
  const CatalogMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  CatalogMetaCompanion toCompanion(bool nullToAbsent) {
    return CatalogMetaCompanion(key: Value(key), value: Value(value));
  }

  factory CatalogMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogMetaData(
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

  CatalogMetaData copyWith({String? key, String? value}) =>
      CatalogMetaData(key: key ?? this.key, value: value ?? this.value);
  CatalogMetaData copyWithCompanion(CatalogMetaCompanion data) {
    return CatalogMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogMetaData(')
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
      (other is CatalogMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class CatalogMetaCompanion extends UpdateCompanion<CatalogMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const CatalogMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<CatalogMetaData> custom({
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

  CatalogMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return CatalogMetaCompanion(
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
    return (StringBuffer('CatalogMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogRegionsTable extends CatalogRegions
    with TableInfo<$CatalogRegionsTable, CatalogRegion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogRegionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, country];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_regions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRegion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogRegion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRegion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
    );
  }

  @override
  $CatalogRegionsTable createAlias(String alias) {
    return $CatalogRegionsTable(attachedDatabase, alias);
  }
}

class CatalogRegion extends DataClass implements Insertable<CatalogRegion> {
  final String id;
  final String name;
  final String country;
  const CatalogRegion({
    required this.id,
    required this.name,
    required this.country,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['country'] = Variable<String>(country);
    return map;
  }

  CatalogRegionsCompanion toCompanion(bool nullToAbsent) {
    return CatalogRegionsCompanion(
      id: Value(id),
      name: Value(name),
      country: Value(country),
    );
  }

  factory CatalogRegion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRegion(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      country: serializer.fromJson<String>(json['country']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'country': serializer.toJson<String>(country),
    };
  }

  CatalogRegion copyWith({String? id, String? name, String? country}) =>
      CatalogRegion(
        id: id ?? this.id,
        name: name ?? this.name,
        country: country ?? this.country,
      );
  CatalogRegion copyWithCompanion(CatalogRegionsCompanion data) {
    return CatalogRegion(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      country: data.country.present ? data.country.value : this.country,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRegion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, country);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRegion &&
          other.id == this.id &&
          other.name == this.name &&
          other.country == this.country);
}

class CatalogRegionsCompanion extends UpdateCompanion<CatalogRegion> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> country;
  final Value<int> rowid;
  const CatalogRegionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogRegionsCompanion.insert({
    required String id,
    required String name,
    required String country,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       country = Value(country);
  static Insertable<CatalogRegion> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? country,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (country != null) 'country': country,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogRegionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? country,
    Value<int>? rowid,
  }) {
    return CatalogRegionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRegionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogAreasTable extends CatalogAreas
    with TableInfo<$CatalogAreasTable, CatalogArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
    'region_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentMeta = const VerificationMeta(
    'document',
  );
  @override
  late final GeneratedColumn<String> document = GeneratedColumn<String>(
    'document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryDocumentMeta = const VerificationMeta(
    'summaryDocument',
  );
  @override
  late final GeneratedColumn<String> summaryDocument = GeneratedColumn<String>(
    'summary_document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    regionId,
    document,
    summaryDocument,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    if (data.containsKey('document')) {
      context.handle(
        _documentMeta,
        document.isAcceptableOrUnknown(data['document']!, _documentMeta),
      );
    } else if (isInserting) {
      context.missing(_documentMeta);
    }
    if (data.containsKey('summary_document')) {
      context.handle(
        _summaryDocumentMeta,
        summaryDocument.isAcceptableOrUnknown(
          data['summary_document']!,
          _summaryDocumentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryDocumentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_id'],
      )!,
      document: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document'],
      )!,
      summaryDocument: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_document'],
      )!,
    );
  }

  @override
  $CatalogAreasTable createAlias(String alias) {
    return $CatalogAreasTable(attachedDatabase, alias);
  }
}

class CatalogArea extends DataClass implements Insertable<CatalogArea> {
  final String id;
  final String regionId;
  final String document;
  final String summaryDocument;
  const CatalogArea({
    required this.id,
    required this.regionId,
    required this.document,
    required this.summaryDocument,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['region_id'] = Variable<String>(regionId);
    map['document'] = Variable<String>(document);
    map['summary_document'] = Variable<String>(summaryDocument);
    return map;
  }

  CatalogAreasCompanion toCompanion(bool nullToAbsent) {
    return CatalogAreasCompanion(
      id: Value(id),
      regionId: Value(regionId),
      document: Value(document),
      summaryDocument: Value(summaryDocument),
    );
  }

  factory CatalogArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogArea(
      id: serializer.fromJson<String>(json['id']),
      regionId: serializer.fromJson<String>(json['regionId']),
      document: serializer.fromJson<String>(json['document']),
      summaryDocument: serializer.fromJson<String>(json['summaryDocument']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'regionId': serializer.toJson<String>(regionId),
      'document': serializer.toJson<String>(document),
      'summaryDocument': serializer.toJson<String>(summaryDocument),
    };
  }

  CatalogArea copyWith({
    String? id,
    String? regionId,
    String? document,
    String? summaryDocument,
  }) => CatalogArea(
    id: id ?? this.id,
    regionId: regionId ?? this.regionId,
    document: document ?? this.document,
    summaryDocument: summaryDocument ?? this.summaryDocument,
  );
  CatalogArea copyWithCompanion(CatalogAreasCompanion data) {
    return CatalogArea(
      id: data.id.present ? data.id.value : this.id,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      document: data.document.present ? data.document.value : this.document,
      summaryDocument: data.summaryDocument.present
          ? data.summaryDocument.value
          : this.summaryDocument,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogArea(')
          ..write('id: $id, ')
          ..write('regionId: $regionId, ')
          ..write('document: $document, ')
          ..write('summaryDocument: $summaryDocument')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, regionId, document, summaryDocument);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogArea &&
          other.id == this.id &&
          other.regionId == this.regionId &&
          other.document == this.document &&
          other.summaryDocument == this.summaryDocument);
}

class CatalogAreasCompanion extends UpdateCompanion<CatalogArea> {
  final Value<String> id;
  final Value<String> regionId;
  final Value<String> document;
  final Value<String> summaryDocument;
  final Value<int> rowid;
  const CatalogAreasCompanion({
    this.id = const Value.absent(),
    this.regionId = const Value.absent(),
    this.document = const Value.absent(),
    this.summaryDocument = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogAreasCompanion.insert({
    required String id,
    required String regionId,
    required String document,
    required String summaryDocument,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       regionId = Value(regionId),
       document = Value(document),
       summaryDocument = Value(summaryDocument);
  static Insertable<CatalogArea> custom({
    Expression<String>? id,
    Expression<String>? regionId,
    Expression<String>? document,
    Expression<String>? summaryDocument,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (regionId != null) 'region_id': regionId,
      if (document != null) 'document': document,
      if (summaryDocument != null) 'summary_document': summaryDocument,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogAreasCompanion copyWith({
    Value<String>? id,
    Value<String>? regionId,
    Value<String>? document,
    Value<String>? summaryDocument,
    Value<int>? rowid,
  }) {
    return CatalogAreasCompanion(
      id: id ?? this.id,
      regionId: regionId ?? this.regionId,
      document: document ?? this.document,
      summaryDocument: summaryDocument ?? this.summaryDocument,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (document.present) {
      map['document'] = Variable<String>(document.value);
    }
    if (summaryDocument.present) {
      map['summary_document'] = Variable<String>(summaryDocument.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogAreasCompanion(')
          ..write('id: $id, ')
          ..write('regionId: $regionId, ')
          ..write('document: $document, ')
          ..write('summaryDocument: $summaryDocument, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogRouteIndexTable extends CatalogRouteIndex
    with TableInfo<$CatalogRouteIndexTable, CatalogRouteIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogRouteIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [routeId, areaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_route_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRouteIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routeId};
  @override
  CatalogRouteIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRouteIndexData(
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      )!,
    );
  }

  @override
  $CatalogRouteIndexTable createAlias(String alias) {
    return $CatalogRouteIndexTable(attachedDatabase, alias);
  }
}

class CatalogRouteIndexData extends DataClass
    implements Insertable<CatalogRouteIndexData> {
  final String routeId;
  final String areaId;
  const CatalogRouteIndexData({required this.routeId, required this.areaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['route_id'] = Variable<String>(routeId);
    map['area_id'] = Variable<String>(areaId);
    return map;
  }

  CatalogRouteIndexCompanion toCompanion(bool nullToAbsent) {
    return CatalogRouteIndexCompanion(
      routeId: Value(routeId),
      areaId: Value(areaId),
    );
  }

  factory CatalogRouteIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRouteIndexData(
      routeId: serializer.fromJson<String>(json['routeId']),
      areaId: serializer.fromJson<String>(json['areaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routeId': serializer.toJson<String>(routeId),
      'areaId': serializer.toJson<String>(areaId),
    };
  }

  CatalogRouteIndexData copyWith({String? routeId, String? areaId}) =>
      CatalogRouteIndexData(
        routeId: routeId ?? this.routeId,
        areaId: areaId ?? this.areaId,
      );
  CatalogRouteIndexData copyWithCompanion(CatalogRouteIndexCompanion data) {
    return CatalogRouteIndexData(
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRouteIndexData(')
          ..write('routeId: $routeId, ')
          ..write('areaId: $areaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(routeId, areaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRouteIndexData &&
          other.routeId == this.routeId &&
          other.areaId == this.areaId);
}

class CatalogRouteIndexCompanion
    extends UpdateCompanion<CatalogRouteIndexData> {
  final Value<String> routeId;
  final Value<String> areaId;
  final Value<int> rowid;
  const CatalogRouteIndexCompanion({
    this.routeId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogRouteIndexCompanion.insert({
    required String routeId,
    required String areaId,
    this.rowid = const Value.absent(),
  }) : routeId = Value(routeId),
       areaId = Value(areaId);
  static Insertable<CatalogRouteIndexData> custom({
    Expression<String>? routeId,
    Expression<String>? areaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routeId != null) 'route_id': routeId,
      if (areaId != null) 'area_id': areaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogRouteIndexCompanion copyWith({
    Value<String>? routeId,
    Value<String>? areaId,
    Value<int>? rowid,
  }) {
    return CatalogRouteIndexCompanion(
      routeId: routeId ?? this.routeId,
      areaId: areaId ?? this.areaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRouteIndexCompanion(')
          ..write('routeId: $routeId, ')
          ..write('areaId: $areaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AscentsTable extends Ascents with TableInfo<$AscentsTable, AscentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AscentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeNameMeta = const VerificationMeta(
    'routeName',
  );
  @override
  late final GeneratedColumn<String> routeName = GeneratedColumn<String>(
    'route_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeValueMeta = const VerificationMeta(
    'gradeValue',
  );
  @override
  late final GeneratedColumn<String> gradeValue = GeneratedColumn<String>(
    'grade_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeSystemMeta = const VerificationMeta(
    'gradeSystem',
  );
  @override
  late final GeneratedColumn<String> gradeSystem = GeneratedColumn<String>(
    'grade_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaNameMeta = const VerificationMeta(
    'areaName',
  );
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
    'area_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorNameMeta = const VerificationMeta(
    'sectorName',
  );
  @override
  late final GeneratedColumn<String> sectorName = GeneratedColumn<String>(
    'sector_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _climbedOnMeta = const VerificationMeta(
    'climbedOn',
  );
  @override
  late final GeneratedColumn<DateTime> climbedOn = GeneratedColumn<DateTime>(
    'climbed_on',
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
  static const VerificationMeta _createdAtMicrosMeta = const VerificationMeta(
    'createdAtMicros',
  );
  @override
  late final GeneratedColumn<int> createdAtMicros = GeneratedColumn<int>(
    'created_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    routeName,
    gradeValue,
    gradeSystem,
    areaId,
    areaName,
    sectorName,
    style,
    climbedOn,
    note,
    createdAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ascents';
  @override
  VerificationContext validateIntegrity(
    Insertable<AscentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('route_name')) {
      context.handle(
        _routeNameMeta,
        routeName.isAcceptableOrUnknown(data['route_name']!, _routeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_routeNameMeta);
    }
    if (data.containsKey('grade_value')) {
      context.handle(
        _gradeValueMeta,
        gradeValue.isAcceptableOrUnknown(data['grade_value']!, _gradeValueMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeValueMeta);
    }
    if (data.containsKey('grade_system')) {
      context.handle(
        _gradeSystemMeta,
        gradeSystem.isAcceptableOrUnknown(
          data['grade_system']!,
          _gradeSystemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gradeSystemMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('area_name')) {
      context.handle(
        _areaNameMeta,
        areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta),
      );
    } else if (isInserting) {
      context.missing(_areaNameMeta);
    }
    if (data.containsKey('sector_name')) {
      context.handle(
        _sectorNameMeta,
        sectorName.isAcceptableOrUnknown(data['sector_name']!, _sectorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorNameMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    } else if (isInserting) {
      context.missing(_styleMeta);
    }
    if (data.containsKey('climbed_on')) {
      context.handle(
        _climbedOnMeta,
        climbedOn.isAcceptableOrUnknown(data['climbed_on']!, _climbedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_climbedOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_micros')) {
      context.handle(
        _createdAtMicrosMeta,
        createdAtMicros.isAcceptableOrUnknown(
          data['created_at_micros']!,
          _createdAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AscentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AscentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      routeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_name'],
      )!,
      gradeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_value'],
      )!,
      gradeSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_system'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      )!,
      areaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_name'],
      )!,
      sectorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_name'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      )!,
      climbedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}climbed_on'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_micros'],
      )!,
    );
  }

  @override
  $AscentsTable createAlias(String alias) {
    return $AscentsTable(attachedDatabase, alias);
  }
}

class AscentRow extends DataClass implements Insertable<AscentRow> {
  final String id;
  final String routeId;
  final String routeName;
  final String gradeValue;
  final String gradeSystem;
  final String areaId;
  final String areaName;
  final String sectorName;
  final String style;
  final DateTime climbedOn;
  final String? note;
  final int createdAtMicros;
  const AscentRow({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.gradeValue,
    required this.gradeSystem,
    required this.areaId,
    required this.areaName,
    required this.sectorName,
    required this.style,
    required this.climbedOn,
    this.note,
    required this.createdAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['route_id'] = Variable<String>(routeId);
    map['route_name'] = Variable<String>(routeName);
    map['grade_value'] = Variable<String>(gradeValue);
    map['grade_system'] = Variable<String>(gradeSystem);
    map['area_id'] = Variable<String>(areaId);
    map['area_name'] = Variable<String>(areaName);
    map['sector_name'] = Variable<String>(sectorName);
    map['style'] = Variable<String>(style);
    map['climbed_on'] = Variable<DateTime>(climbedOn);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_micros'] = Variable<int>(createdAtMicros);
    return map;
  }

  AscentsCompanion toCompanion(bool nullToAbsent) {
    return AscentsCompanion(
      id: Value(id),
      routeId: Value(routeId),
      routeName: Value(routeName),
      gradeValue: Value(gradeValue),
      gradeSystem: Value(gradeSystem),
      areaId: Value(areaId),
      areaName: Value(areaName),
      sectorName: Value(sectorName),
      style: Value(style),
      climbedOn: Value(climbedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtMicros: Value(createdAtMicros),
    );
  }

  factory AscentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AscentRow(
      id: serializer.fromJson<String>(json['id']),
      routeId: serializer.fromJson<String>(json['routeId']),
      routeName: serializer.fromJson<String>(json['routeName']),
      gradeValue: serializer.fromJson<String>(json['gradeValue']),
      gradeSystem: serializer.fromJson<String>(json['gradeSystem']),
      areaId: serializer.fromJson<String>(json['areaId']),
      areaName: serializer.fromJson<String>(json['areaName']),
      sectorName: serializer.fromJson<String>(json['sectorName']),
      style: serializer.fromJson<String>(json['style']),
      climbedOn: serializer.fromJson<DateTime>(json['climbedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtMicros: serializer.fromJson<int>(json['createdAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routeId': serializer.toJson<String>(routeId),
      'routeName': serializer.toJson<String>(routeName),
      'gradeValue': serializer.toJson<String>(gradeValue),
      'gradeSystem': serializer.toJson<String>(gradeSystem),
      'areaId': serializer.toJson<String>(areaId),
      'areaName': serializer.toJson<String>(areaName),
      'sectorName': serializer.toJson<String>(sectorName),
      'style': serializer.toJson<String>(style),
      'climbedOn': serializer.toJson<DateTime>(climbedOn),
      'note': serializer.toJson<String?>(note),
      'createdAtMicros': serializer.toJson<int>(createdAtMicros),
    };
  }

  AscentRow copyWith({
    String? id,
    String? routeId,
    String? routeName,
    String? gradeValue,
    String? gradeSystem,
    String? areaId,
    String? areaName,
    String? sectorName,
    String? style,
    DateTime? climbedOn,
    Value<String?> note = const Value.absent(),
    int? createdAtMicros,
  }) => AscentRow(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    routeName: routeName ?? this.routeName,
    gradeValue: gradeValue ?? this.gradeValue,
    gradeSystem: gradeSystem ?? this.gradeSystem,
    areaId: areaId ?? this.areaId,
    areaName: areaName ?? this.areaName,
    sectorName: sectorName ?? this.sectorName,
    style: style ?? this.style,
    climbedOn: climbedOn ?? this.climbedOn,
    note: note.present ? note.value : this.note,
    createdAtMicros: createdAtMicros ?? this.createdAtMicros,
  );
  AscentRow copyWithCompanion(AscentsCompanion data) {
    return AscentRow(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      routeName: data.routeName.present ? data.routeName.value : this.routeName,
      gradeValue: data.gradeValue.present
          ? data.gradeValue.value
          : this.gradeValue,
      gradeSystem: data.gradeSystem.present
          ? data.gradeSystem.value
          : this.gradeSystem,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      sectorName: data.sectorName.present
          ? data.sectorName.value
          : this.sectorName,
      style: data.style.present ? data.style.value : this.style,
      climbedOn: data.climbedOn.present ? data.climbedOn.value : this.climbedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAtMicros: data.createdAtMicros.present
          ? data.createdAtMicros.value
          : this.createdAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AscentRow(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('routeName: $routeName, ')
          ..write('gradeValue: $gradeValue, ')
          ..write('gradeSystem: $gradeSystem, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('sectorName: $sectorName, ')
          ..write('style: $style, ')
          ..write('climbedOn: $climbedOn, ')
          ..write('note: $note, ')
          ..write('createdAtMicros: $createdAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeId,
    routeName,
    gradeValue,
    gradeSystem,
    areaId,
    areaName,
    sectorName,
    style,
    climbedOn,
    note,
    createdAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AscentRow &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.routeName == this.routeName &&
          other.gradeValue == this.gradeValue &&
          other.gradeSystem == this.gradeSystem &&
          other.areaId == this.areaId &&
          other.areaName == this.areaName &&
          other.sectorName == this.sectorName &&
          other.style == this.style &&
          other.climbedOn == this.climbedOn &&
          other.note == this.note &&
          other.createdAtMicros == this.createdAtMicros);
}

class AscentsCompanion extends UpdateCompanion<AscentRow> {
  final Value<String> id;
  final Value<String> routeId;
  final Value<String> routeName;
  final Value<String> gradeValue;
  final Value<String> gradeSystem;
  final Value<String> areaId;
  final Value<String> areaName;
  final Value<String> sectorName;
  final Value<String> style;
  final Value<DateTime> climbedOn;
  final Value<String?> note;
  final Value<int> createdAtMicros;
  final Value<int> rowid;
  const AscentsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.routeName = const Value.absent(),
    this.gradeValue = const Value.absent(),
    this.gradeSystem = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.sectorName = const Value.absent(),
    this.style = const Value.absent(),
    this.climbedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AscentsCompanion.insert({
    required String id,
    required String routeId,
    required String routeName,
    required String gradeValue,
    required String gradeSystem,
    required String areaId,
    required String areaName,
    required String sectorName,
    required String style,
    required DateTime climbedOn,
    this.note = const Value.absent(),
    required int createdAtMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routeId = Value(routeId),
       routeName = Value(routeName),
       gradeValue = Value(gradeValue),
       gradeSystem = Value(gradeSystem),
       areaId = Value(areaId),
       areaName = Value(areaName),
       sectorName = Value(sectorName),
       style = Value(style),
       climbedOn = Value(climbedOn),
       createdAtMicros = Value(createdAtMicros);
  static Insertable<AscentRow> custom({
    Expression<String>? id,
    Expression<String>? routeId,
    Expression<String>? routeName,
    Expression<String>? gradeValue,
    Expression<String>? gradeSystem,
    Expression<String>? areaId,
    Expression<String>? areaName,
    Expression<String>? sectorName,
    Expression<String>? style,
    Expression<DateTime>? climbedOn,
    Expression<String>? note,
    Expression<int>? createdAtMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (routeName != null) 'route_name': routeName,
      if (gradeValue != null) 'grade_value': gradeValue,
      if (gradeSystem != null) 'grade_system': gradeSystem,
      if (areaId != null) 'area_id': areaId,
      if (areaName != null) 'area_name': areaName,
      if (sectorName != null) 'sector_name': sectorName,
      if (style != null) 'style': style,
      if (climbedOn != null) 'climbed_on': climbedOn,
      if (note != null) 'note': note,
      if (createdAtMicros != null) 'created_at_micros': createdAtMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AscentsCompanion copyWith({
    Value<String>? id,
    Value<String>? routeId,
    Value<String>? routeName,
    Value<String>? gradeValue,
    Value<String>? gradeSystem,
    Value<String>? areaId,
    Value<String>? areaName,
    Value<String>? sectorName,
    Value<String>? style,
    Value<DateTime>? climbedOn,
    Value<String?>? note,
    Value<int>? createdAtMicros,
    Value<int>? rowid,
  }) {
    return AscentsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      gradeValue: gradeValue ?? this.gradeValue,
      gradeSystem: gradeSystem ?? this.gradeSystem,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      sectorName: sectorName ?? this.sectorName,
      style: style ?? this.style,
      climbedOn: climbedOn ?? this.climbedOn,
      note: note ?? this.note,
      createdAtMicros: createdAtMicros ?? this.createdAtMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (routeName.present) {
      map['route_name'] = Variable<String>(routeName.value);
    }
    if (gradeValue.present) {
      map['grade_value'] = Variable<String>(gradeValue.value);
    }
    if (gradeSystem.present) {
      map['grade_system'] = Variable<String>(gradeSystem.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (sectorName.present) {
      map['sector_name'] = Variable<String>(sectorName.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (climbedOn.present) {
      map['climbed_on'] = Variable<DateTime>(climbedOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtMicros.present) {
      map['created_at_micros'] = Variable<int>(createdAtMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AscentsCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('routeName: $routeName, ')
          ..write('gradeValue: $gradeValue, ')
          ..write('gradeSystem: $gradeSystem, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('sectorName: $sectorName, ')
          ..write('style: $style, ')
          ..write('climbedOn: $climbedOn, ')
          ..write('note: $note, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CruxDatabase extends GeneratedDatabase {
  _$CruxDatabase(QueryExecutor e) : super(e);
  $CruxDatabaseManager get managers => $CruxDatabaseManager(this);
  late final $UserRouteFlagsTable userRouteFlags = $UserRouteFlagsTable(this);
  late final $RecentAreaViewsTable recentAreaViews = $RecentAreaViewsTable(
    this,
  );
  late final $CatalogMetaTable catalogMeta = $CatalogMetaTable(this);
  late final $CatalogRegionsTable catalogRegions = $CatalogRegionsTable(this);
  late final $CatalogAreasTable catalogAreas = $CatalogAreasTable(this);
  late final $CatalogRouteIndexTable catalogRouteIndex =
      $CatalogRouteIndexTable(this);
  late final $AscentsTable ascents = $AscentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userRouteFlags,
    recentAreaViews,
    catalogMeta,
    catalogRegions,
    catalogAreas,
    catalogRouteIndex,
    ascents,
  ];
}

typedef $$UserRouteFlagsTableCreateCompanionBuilder =
    UserRouteFlagsCompanion Function({
      required String routeId,
      Value<bool> isFavorite,
      Value<bool> isProject,
      Value<int> rowid,
    });
typedef $$UserRouteFlagsTableUpdateCompanionBuilder =
    UserRouteFlagsCompanion Function({
      Value<String> routeId,
      Value<bool> isFavorite,
      Value<bool> isProject,
      Value<int> rowid,
    });

class $$UserRouteFlagsTableFilterComposer
    extends Composer<_$CruxDatabase, $UserRouteFlagsTable> {
  $$UserRouteFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProject => $composableBuilder(
    column: $table.isProject,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRouteFlagsTableOrderingComposer
    extends Composer<_$CruxDatabase, $UserRouteFlagsTable> {
  $$UserRouteFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProject => $composableBuilder(
    column: $table.isProject,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRouteFlagsTableAnnotationComposer
    extends Composer<_$CruxDatabase, $UserRouteFlagsTable> {
  $$UserRouteFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isProject =>
      $composableBuilder(column: $table.isProject, builder: (column) => column);
}

class $$UserRouteFlagsTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $UserRouteFlagsTable,
          UserRouteFlag,
          $$UserRouteFlagsTableFilterComposer,
          $$UserRouteFlagsTableOrderingComposer,
          $$UserRouteFlagsTableAnnotationComposer,
          $$UserRouteFlagsTableCreateCompanionBuilder,
          $$UserRouteFlagsTableUpdateCompanionBuilder,
          (
            UserRouteFlag,
            BaseReferences<_$CruxDatabase, $UserRouteFlagsTable, UserRouteFlag>,
          ),
          UserRouteFlag,
          PrefetchHooks Function()
        > {
  $$UserRouteFlagsTableTableManager(
    _$CruxDatabase db,
    $UserRouteFlagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRouteFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRouteFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRouteFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> routeId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isProject = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRouteFlagsCompanion(
                routeId: routeId,
                isFavorite: isFavorite,
                isProject: isProject,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String routeId,
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isProject = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRouteFlagsCompanion.insert(
                routeId: routeId,
                isFavorite: isFavorite,
                isProject: isProject,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserRouteFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $UserRouteFlagsTable,
      UserRouteFlag,
      $$UserRouteFlagsTableFilterComposer,
      $$UserRouteFlagsTableOrderingComposer,
      $$UserRouteFlagsTableAnnotationComposer,
      $$UserRouteFlagsTableCreateCompanionBuilder,
      $$UserRouteFlagsTableUpdateCompanionBuilder,
      (
        UserRouteFlag,
        BaseReferences<_$CruxDatabase, $UserRouteFlagsTable, UserRouteFlag>,
      ),
      UserRouteFlag,
      PrefetchHooks Function()
    >;
typedef $$RecentAreaViewsTableCreateCompanionBuilder =
    RecentAreaViewsCompanion Function({
      required String areaId,
      required int viewedAtMicros,
      Value<int> rowid,
    });
typedef $$RecentAreaViewsTableUpdateCompanionBuilder =
    RecentAreaViewsCompanion Function({
      Value<String> areaId,
      Value<int> viewedAtMicros,
      Value<int> rowid,
    });

class $$RecentAreaViewsTableFilterComposer
    extends Composer<_$CruxDatabase, $RecentAreaViewsTable> {
  $$RecentAreaViewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewedAtMicros => $composableBuilder(
    column: $table.viewedAtMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentAreaViewsTableOrderingComposer
    extends Composer<_$CruxDatabase, $RecentAreaViewsTable> {
  $$RecentAreaViewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewedAtMicros => $composableBuilder(
    column: $table.viewedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentAreaViewsTableAnnotationComposer
    extends Composer<_$CruxDatabase, $RecentAreaViewsTable> {
  $$RecentAreaViewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<int> get viewedAtMicros => $composableBuilder(
    column: $table.viewedAtMicros,
    builder: (column) => column,
  );
}

class $$RecentAreaViewsTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $RecentAreaViewsTable,
          RecentAreaView,
          $$RecentAreaViewsTableFilterComposer,
          $$RecentAreaViewsTableOrderingComposer,
          $$RecentAreaViewsTableAnnotationComposer,
          $$RecentAreaViewsTableCreateCompanionBuilder,
          $$RecentAreaViewsTableUpdateCompanionBuilder,
          (
            RecentAreaView,
            BaseReferences<
              _$CruxDatabase,
              $RecentAreaViewsTable,
              RecentAreaView
            >,
          ),
          RecentAreaView,
          PrefetchHooks Function()
        > {
  $$RecentAreaViewsTableTableManager(
    _$CruxDatabase db,
    $RecentAreaViewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentAreaViewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentAreaViewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentAreaViewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> areaId = const Value.absent(),
                Value<int> viewedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentAreaViewsCompanion(
                areaId: areaId,
                viewedAtMicros: viewedAtMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String areaId,
                required int viewedAtMicros,
                Value<int> rowid = const Value.absent(),
              }) => RecentAreaViewsCompanion.insert(
                areaId: areaId,
                viewedAtMicros: viewedAtMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentAreaViewsTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $RecentAreaViewsTable,
      RecentAreaView,
      $$RecentAreaViewsTableFilterComposer,
      $$RecentAreaViewsTableOrderingComposer,
      $$RecentAreaViewsTableAnnotationComposer,
      $$RecentAreaViewsTableCreateCompanionBuilder,
      $$RecentAreaViewsTableUpdateCompanionBuilder,
      (
        RecentAreaView,
        BaseReferences<_$CruxDatabase, $RecentAreaViewsTable, RecentAreaView>,
      ),
      RecentAreaView,
      PrefetchHooks Function()
    >;
typedef $$CatalogMetaTableCreateCompanionBuilder =
    CatalogMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$CatalogMetaTableUpdateCompanionBuilder =
    CatalogMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$CatalogMetaTableFilterComposer
    extends Composer<_$CruxDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogMetaTableOrderingComposer
    extends Composer<_$CruxDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogMetaTableAnnotationComposer
    extends Composer<_$CruxDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableAnnotationComposer({
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
}

class $$CatalogMetaTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $CatalogMetaTable,
          CatalogMetaData,
          $$CatalogMetaTableFilterComposer,
          $$CatalogMetaTableOrderingComposer,
          $$CatalogMetaTableAnnotationComposer,
          $$CatalogMetaTableCreateCompanionBuilder,
          $$CatalogMetaTableUpdateCompanionBuilder,
          (
            CatalogMetaData,
            BaseReferences<_$CruxDatabase, $CatalogMetaTable, CatalogMetaData>,
          ),
          CatalogMetaData,
          PrefetchHooks Function()
        > {
  $$CatalogMetaTableTableManager(_$CruxDatabase db, $CatalogMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => CatalogMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $CatalogMetaTable,
      CatalogMetaData,
      $$CatalogMetaTableFilterComposer,
      $$CatalogMetaTableOrderingComposer,
      $$CatalogMetaTableAnnotationComposer,
      $$CatalogMetaTableCreateCompanionBuilder,
      $$CatalogMetaTableUpdateCompanionBuilder,
      (
        CatalogMetaData,
        BaseReferences<_$CruxDatabase, $CatalogMetaTable, CatalogMetaData>,
      ),
      CatalogMetaData,
      PrefetchHooks Function()
    >;
typedef $$CatalogRegionsTableCreateCompanionBuilder =
    CatalogRegionsCompanion Function({
      required String id,
      required String name,
      required String country,
      Value<int> rowid,
    });
typedef $$CatalogRegionsTableUpdateCompanionBuilder =
    CatalogRegionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> country,
      Value<int> rowid,
    });

class $$CatalogRegionsTableFilterComposer
    extends Composer<_$CruxDatabase, $CatalogRegionsTable> {
  $$CatalogRegionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogRegionsTableOrderingComposer
    extends Composer<_$CruxDatabase, $CatalogRegionsTable> {
  $$CatalogRegionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogRegionsTableAnnotationComposer
    extends Composer<_$CruxDatabase, $CatalogRegionsTable> {
  $$CatalogRegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);
}

class $$CatalogRegionsTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $CatalogRegionsTable,
          CatalogRegion,
          $$CatalogRegionsTableFilterComposer,
          $$CatalogRegionsTableOrderingComposer,
          $$CatalogRegionsTableAnnotationComposer,
          $$CatalogRegionsTableCreateCompanionBuilder,
          $$CatalogRegionsTableUpdateCompanionBuilder,
          (
            CatalogRegion,
            BaseReferences<_$CruxDatabase, $CatalogRegionsTable, CatalogRegion>,
          ),
          CatalogRegion,
          PrefetchHooks Function()
        > {
  $$CatalogRegionsTableTableManager(
    _$CruxDatabase db,
    $CatalogRegionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogRegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogRegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogRegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRegionsCompanion(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String country,
                Value<int> rowid = const Value.absent(),
              }) => CatalogRegionsCompanion.insert(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogRegionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $CatalogRegionsTable,
      CatalogRegion,
      $$CatalogRegionsTableFilterComposer,
      $$CatalogRegionsTableOrderingComposer,
      $$CatalogRegionsTableAnnotationComposer,
      $$CatalogRegionsTableCreateCompanionBuilder,
      $$CatalogRegionsTableUpdateCompanionBuilder,
      (
        CatalogRegion,
        BaseReferences<_$CruxDatabase, $CatalogRegionsTable, CatalogRegion>,
      ),
      CatalogRegion,
      PrefetchHooks Function()
    >;
typedef $$CatalogAreasTableCreateCompanionBuilder =
    CatalogAreasCompanion Function({
      required String id,
      required String regionId,
      required String document,
      required String summaryDocument,
      Value<int> rowid,
    });
typedef $$CatalogAreasTableUpdateCompanionBuilder =
    CatalogAreasCompanion Function({
      Value<String> id,
      Value<String> regionId,
      Value<String> document,
      Value<String> summaryDocument,
      Value<int> rowid,
    });

class $$CatalogAreasTableFilterComposer
    extends Composer<_$CruxDatabase, $CatalogAreasTable> {
  $$CatalogAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryDocument => $composableBuilder(
    column: $table.summaryDocument,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogAreasTableOrderingComposer
    extends Composer<_$CruxDatabase, $CatalogAreasTable> {
  $$CatalogAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryDocument => $composableBuilder(
    column: $table.summaryDocument,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogAreasTableAnnotationComposer
    extends Composer<_$CruxDatabase, $CatalogAreasTable> {
  $$CatalogAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get document =>
      $composableBuilder(column: $table.document, builder: (column) => column);

  GeneratedColumn<String> get summaryDocument => $composableBuilder(
    column: $table.summaryDocument,
    builder: (column) => column,
  );
}

class $$CatalogAreasTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $CatalogAreasTable,
          CatalogArea,
          $$CatalogAreasTableFilterComposer,
          $$CatalogAreasTableOrderingComposer,
          $$CatalogAreasTableAnnotationComposer,
          $$CatalogAreasTableCreateCompanionBuilder,
          $$CatalogAreasTableUpdateCompanionBuilder,
          (
            CatalogArea,
            BaseReferences<_$CruxDatabase, $CatalogAreasTable, CatalogArea>,
          ),
          CatalogArea,
          PrefetchHooks Function()
        > {
  $$CatalogAreasTableTableManager(_$CruxDatabase db, $CatalogAreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> regionId = const Value.absent(),
                Value<String> document = const Value.absent(),
                Value<String> summaryDocument = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogAreasCompanion(
                id: id,
                regionId: regionId,
                document: document,
                summaryDocument: summaryDocument,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String regionId,
                required String document,
                required String summaryDocument,
                Value<int> rowid = const Value.absent(),
              }) => CatalogAreasCompanion.insert(
                id: id,
                regionId: regionId,
                document: document,
                summaryDocument: summaryDocument,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogAreasTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $CatalogAreasTable,
      CatalogArea,
      $$CatalogAreasTableFilterComposer,
      $$CatalogAreasTableOrderingComposer,
      $$CatalogAreasTableAnnotationComposer,
      $$CatalogAreasTableCreateCompanionBuilder,
      $$CatalogAreasTableUpdateCompanionBuilder,
      (
        CatalogArea,
        BaseReferences<_$CruxDatabase, $CatalogAreasTable, CatalogArea>,
      ),
      CatalogArea,
      PrefetchHooks Function()
    >;
typedef $$CatalogRouteIndexTableCreateCompanionBuilder =
    CatalogRouteIndexCompanion Function({
      required String routeId,
      required String areaId,
      Value<int> rowid,
    });
typedef $$CatalogRouteIndexTableUpdateCompanionBuilder =
    CatalogRouteIndexCompanion Function({
      Value<String> routeId,
      Value<String> areaId,
      Value<int> rowid,
    });

class $$CatalogRouteIndexTableFilterComposer
    extends Composer<_$CruxDatabase, $CatalogRouteIndexTable> {
  $$CatalogRouteIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogRouteIndexTableOrderingComposer
    extends Composer<_$CruxDatabase, $CatalogRouteIndexTable> {
  $$CatalogRouteIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogRouteIndexTableAnnotationComposer
    extends Composer<_$CruxDatabase, $CatalogRouteIndexTable> {
  $$CatalogRouteIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);
}

class $$CatalogRouteIndexTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $CatalogRouteIndexTable,
          CatalogRouteIndexData,
          $$CatalogRouteIndexTableFilterComposer,
          $$CatalogRouteIndexTableOrderingComposer,
          $$CatalogRouteIndexTableAnnotationComposer,
          $$CatalogRouteIndexTableCreateCompanionBuilder,
          $$CatalogRouteIndexTableUpdateCompanionBuilder,
          (
            CatalogRouteIndexData,
            BaseReferences<
              _$CruxDatabase,
              $CatalogRouteIndexTable,
              CatalogRouteIndexData
            >,
          ),
          CatalogRouteIndexData,
          PrefetchHooks Function()
        > {
  $$CatalogRouteIndexTableTableManager(
    _$CruxDatabase db,
    $CatalogRouteIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogRouteIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogRouteIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogRouteIndexTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> routeId = const Value.absent(),
                Value<String> areaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRouteIndexCompanion(
                routeId: routeId,
                areaId: areaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String routeId,
                required String areaId,
                Value<int> rowid = const Value.absent(),
              }) => CatalogRouteIndexCompanion.insert(
                routeId: routeId,
                areaId: areaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogRouteIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $CatalogRouteIndexTable,
      CatalogRouteIndexData,
      $$CatalogRouteIndexTableFilterComposer,
      $$CatalogRouteIndexTableOrderingComposer,
      $$CatalogRouteIndexTableAnnotationComposer,
      $$CatalogRouteIndexTableCreateCompanionBuilder,
      $$CatalogRouteIndexTableUpdateCompanionBuilder,
      (
        CatalogRouteIndexData,
        BaseReferences<
          _$CruxDatabase,
          $CatalogRouteIndexTable,
          CatalogRouteIndexData
        >,
      ),
      CatalogRouteIndexData,
      PrefetchHooks Function()
    >;
typedef $$AscentsTableCreateCompanionBuilder =
    AscentsCompanion Function({
      required String id,
      required String routeId,
      required String routeName,
      required String gradeValue,
      required String gradeSystem,
      required String areaId,
      required String areaName,
      required String sectorName,
      required String style,
      required DateTime climbedOn,
      Value<String?> note,
      required int createdAtMicros,
      Value<int> rowid,
    });
typedef $$AscentsTableUpdateCompanionBuilder =
    AscentsCompanion Function({
      Value<String> id,
      Value<String> routeId,
      Value<String> routeName,
      Value<String> gradeValue,
      Value<String> gradeSystem,
      Value<String> areaId,
      Value<String> areaName,
      Value<String> sectorName,
      Value<String> style,
      Value<DateTime> climbedOn,
      Value<String?> note,
      Value<int> createdAtMicros,
      Value<int> rowid,
    });

class $$AscentsTableFilterComposer
    extends Composer<_$CruxDatabase, $AscentsTable> {
  $$AscentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeName => $composableBuilder(
    column: $table.routeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectorName => $composableBuilder(
    column: $table.sectorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get climbedOn => $composableBuilder(
    column: $table.climbedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AscentsTableOrderingComposer
    extends Composer<_$CruxDatabase, $AscentsTable> {
  $$AscentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeName => $composableBuilder(
    column: $table.routeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectorName => $composableBuilder(
    column: $table.sectorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get climbedOn => $composableBuilder(
    column: $table.climbedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AscentsTableAnnotationComposer
    extends Composer<_$CruxDatabase, $AscentsTable> {
  $$AscentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<String> get routeName =>
      $composableBuilder(column: $table.routeName, builder: (column) => column);

  GeneratedColumn<String> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<String> get sectorName => $composableBuilder(
    column: $table.sectorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<DateTime> get climbedOn =>
      $composableBuilder(column: $table.climbedOn, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => column,
  );
}

class $$AscentsTableTableManager
    extends
        RootTableManager<
          _$CruxDatabase,
          $AscentsTable,
          AscentRow,
          $$AscentsTableFilterComposer,
          $$AscentsTableOrderingComposer,
          $$AscentsTableAnnotationComposer,
          $$AscentsTableCreateCompanionBuilder,
          $$AscentsTableUpdateCompanionBuilder,
          (AscentRow, BaseReferences<_$CruxDatabase, $AscentsTable, AscentRow>),
          AscentRow,
          PrefetchHooks Function()
        > {
  $$AscentsTableTableManager(_$CruxDatabase db, $AscentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AscentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AscentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AscentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routeId = const Value.absent(),
                Value<String> routeName = const Value.absent(),
                Value<String> gradeValue = const Value.absent(),
                Value<String> gradeSystem = const Value.absent(),
                Value<String> areaId = const Value.absent(),
                Value<String> areaName = const Value.absent(),
                Value<String> sectorName = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<DateTime> climbedOn = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AscentsCompanion(
                id: id,
                routeId: routeId,
                routeName: routeName,
                gradeValue: gradeValue,
                gradeSystem: gradeSystem,
                areaId: areaId,
                areaName: areaName,
                sectorName: sectorName,
                style: style,
                climbedOn: climbedOn,
                note: note,
                createdAtMicros: createdAtMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routeId,
                required String routeName,
                required String gradeValue,
                required String gradeSystem,
                required String areaId,
                required String areaName,
                required String sectorName,
                required String style,
                required DateTime climbedOn,
                Value<String?> note = const Value.absent(),
                required int createdAtMicros,
                Value<int> rowid = const Value.absent(),
              }) => AscentsCompanion.insert(
                id: id,
                routeId: routeId,
                routeName: routeName,
                gradeValue: gradeValue,
                gradeSystem: gradeSystem,
                areaId: areaId,
                areaName: areaName,
                sectorName: sectorName,
                style: style,
                climbedOn: climbedOn,
                note: note,
                createdAtMicros: createdAtMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AscentsTableProcessedTableManager =
    ProcessedTableManager<
      _$CruxDatabase,
      $AscentsTable,
      AscentRow,
      $$AscentsTableFilterComposer,
      $$AscentsTableOrderingComposer,
      $$AscentsTableAnnotationComposer,
      $$AscentsTableCreateCompanionBuilder,
      $$AscentsTableUpdateCompanionBuilder,
      (AscentRow, BaseReferences<_$CruxDatabase, $AscentsTable, AscentRow>),
      AscentRow,
      PrefetchHooks Function()
    >;

class $CruxDatabaseManager {
  final _$CruxDatabase _db;
  $CruxDatabaseManager(this._db);
  $$UserRouteFlagsTableTableManager get userRouteFlags =>
      $$UserRouteFlagsTableTableManager(_db, _db.userRouteFlags);
  $$RecentAreaViewsTableTableManager get recentAreaViews =>
      $$RecentAreaViewsTableTableManager(_db, _db.recentAreaViews);
  $$CatalogMetaTableTableManager get catalogMeta =>
      $$CatalogMetaTableTableManager(_db, _db.catalogMeta);
  $$CatalogRegionsTableTableManager get catalogRegions =>
      $$CatalogRegionsTableTableManager(_db, _db.catalogRegions);
  $$CatalogAreasTableTableManager get catalogAreas =>
      $$CatalogAreasTableTableManager(_db, _db.catalogAreas);
  $$CatalogRouteIndexTableTableManager get catalogRouteIndex =>
      $$CatalogRouteIndexTableTableManager(_db, _db.catalogRouteIndex);
  $$AscentsTableTableManager get ascents =>
      $$AscentsTableTableManager(_db, _db.ascents);
}
