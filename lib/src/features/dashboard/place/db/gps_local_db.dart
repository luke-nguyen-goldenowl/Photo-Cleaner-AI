import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/image_location.dart';

class GpsCacheDb {
  factory GpsCacheDb() => instance;
  GpsCacheDb._internal();

  static final GpsCacheDb instance = GpsCacheDb._internal();
  static GpsCacheDb get I => instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gps_cache.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gps_cache (
            imageId TEXT PRIMARY KEY,
            latitude REAL,
            longitude REAL,
            imagePath TEXT,
            thumbnailPath TEXT,
            dateTime TEXT
          )
        ''');
      },
    );
  }

  Future<MImageLocation?> get(String imageId) async {
    final database = await db;
    final maps = await database.query(
      'gps_cache',
      where: 'imageId = ?',
      whereArgs: [imageId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    return MImageLocation(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      imagePath: map['imagePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String,
      imageId: map['imageId'] as String,
      dateTime: map['dateTime'] != null
          ? DateTime.tryParse(map['dateTime'] as String)
          : null,
    );
  }

  Future<void> put(MImageLocation location) async {
    final database = await db;
    await database.insert(
      'gps_cache',
      {
        'imageId': location.imageId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'imagePath': location.imagePath,
        'thumbnailPath': location.thumbnailPath,
        'dateTime': location.dateTime?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String imageId) async {
    final database = await db;
    await database.delete(
      'gps_cache',
      where: 'imageId = ?',
      whereArgs: [imageId],
    );
  }

  Future<void> clear() async {
    final database = await db;
    await database.delete('gps_cache');
  }
}
