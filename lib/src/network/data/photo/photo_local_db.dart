import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// ignore: camel_case_types
class _keys {
  static const String databaseName = 'photo_app.db';
  static const int databaseVersion = 1;
  static const String tableFavorites = 'favorites';
  static const String columnPhotoId = 'photo_id';
  static const String columnUserId = 'user_id';
  static const String columnCreatedAt = 'created_at';
}

class PhotoLocalDatabase {
  factory PhotoLocalDatabase() => instance;
  PhotoLocalDatabase._internal();

  static final PhotoLocalDatabase instance = PhotoLocalDatabase._internal();
  static PhotoLocalDatabase get I => instance;
  late Database _db;

  Future<void> initialize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _keys.databaseName);
    _db = await openDatabase(
      path,
      version: _keys.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${_keys.tableFavorites} (
        ${_keys.columnPhotoId} TEXT NOT NULL,
        ${_keys.columnUserId} TEXT NOT NULL,
        ${_keys.columnCreatedAt} INTEGER NOT NULL,
        PRIMARY KEY (${_keys.columnPhotoId}, ${_keys.columnUserId})
      )
    ''');
  }

  Future<int> insertFavorite(String photoId, String userId) async {
    return await _db.insert(
      _keys.tableFavorites,
      {
        _keys.columnPhotoId: photoId,
        _keys.columnUserId: userId,
        _keys.columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteFavorite(String photoId, String userId) async {
    return await _db.delete(
      _keys.tableFavorites,
      where: '${_keys.columnPhotoId} = ? AND ${_keys.columnUserId} = ?',
      whereArgs: [photoId, userId],
    );
  }

  Future<bool> isFavorite(String photoId, String userId) async {
    final result = await _db.query(
      _keys.tableFavorites,
      where: '${_keys.columnPhotoId} = ? AND ${_keys.columnUserId} = ?',
      whereArgs: [photoId, userId],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAllFavorites(String userId) async {
    final result = await _db.query(
      _keys.tableFavorites,
      where: '${_keys.columnUserId} = ?',
      whereArgs: [userId],
      orderBy: '${_keys.columnCreatedAt} DESC',
    );
    return result.map((row) => row[_keys.columnPhotoId] as String).toList();
  }

  Future<int> clearAllFavorites() async {
    return await _db.delete(_keys.tableFavorites);
  }
}
