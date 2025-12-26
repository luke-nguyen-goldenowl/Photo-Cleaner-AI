import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/image_location.dart';

// ignore: camel_case_types
class _keys {
  static const String databaseName = 'gps_cache.db';
  static const int databaseVersion = 1;
  static const String tableGpsCache = 'gps_cache';
  static const String columnImageId = 'imageId';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnImagePath = 'imagePath';
  static const String columnDateTime = 'dateTime';
}

class GpsCacheDb {
  factory GpsCacheDb() => instance;
  GpsCacheDb._internal();

  static final GpsCacheDb instance = GpsCacheDb._internal();
  static GpsCacheDb get I => instance;
  late Database _db;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _keys.databaseName);
    _db = await openDatabase(
      path,
      version: _keys.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${_keys.tableGpsCache} (
        ${_keys.columnImageId} TEXT PRIMARY KEY,
        ${_keys.columnLatitude} REAL,
        ${_keys.columnLongitude} REAL,
        ${_keys.columnImagePath} TEXT,
        ${_keys.columnDateTime} TEXT
      )
    ''');
  }

  Future<MImageLocation?> get(String imageId) async {
    final maps = await _db.query(
      _keys.tableGpsCache,
      where: '${_keys.columnImageId} = ?',
      whereArgs: [imageId],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final map = maps.first;
    return MImageLocation(
      latitude: map[_keys.columnLatitude] as double,
      longitude: map[_keys.columnLongitude] as double,
      imagePath: map[_keys.columnImagePath] as String,
      imageId: map[_keys.columnImageId] as String,
      dateTime: map[_keys.columnDateTime] != null
          ? DateTime.tryParse(map[_keys.columnDateTime] as String)
          : null,
    );
  }

  Future<void> put(MImageLocation location) async {
    await _db.insert(
      _keys.tableGpsCache,
      {
        _keys.columnImageId: location.imageId,
        _keys.columnLatitude: location.latitude,
        _keys.columnLongitude: location.longitude,
        _keys.columnImagePath: location.imagePath,
        _keys.columnDateTime: location.dateTime?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String imageId) async {
    await _db.delete(
      _keys.tableGpsCache,
      where: '${_keys.columnImageId} = ?',
      whereArgs: [imageId],
    );
  }

  Future<void> clear() async {
    await _db.delete(_keys.tableGpsCache);
  }
}
