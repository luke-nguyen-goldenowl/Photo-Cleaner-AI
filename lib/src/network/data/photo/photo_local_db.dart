import 'package:myapp/src/features/dashboard/photo/model/favorite_photo.dart';
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
  static const String columnImagePath = 'image_path';
  static const String columnImageUrl = 'image_url';
  static const String columnSyncStatus = 'sync_status';
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
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${_keys.tableFavorites} (
        ${_keys.columnPhotoId} TEXT NOT NULL,
        ${_keys.columnUserId} TEXT NOT NULL,
        ${_keys.columnCreatedAt} INTEGER NOT NULL,
        ${_keys.columnImagePath} TEXT,
        ${_keys.columnImageUrl} TEXT,
        ${_keys.columnSyncStatus} TEXT DEFAULT 'pending',
        PRIMARY KEY (${_keys.columnPhotoId}, ${_keys.columnUserId})
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE ${_keys.tableFavorites} 
        ADD COLUMN ${_keys.columnImagePath} TEXT
      ''');
      await db.execute('''
        ALTER TABLE ${_keys.tableFavorites} 
        ADD COLUMN ${_keys.columnImageUrl} TEXT
      ''');
      await db.execute('''
        ALTER TABLE ${_keys.tableFavorites} 
        ADD COLUMN ${_keys.columnSyncStatus} TEXT DEFAULT 'pending'
      ''');
      await db.execute('''
        UPDATE ${_keys.tableFavorites} 
        SET ${_keys.columnSyncStatus} = 'synced'
      ''');
    }
  }

  Future<int> insertFavoriteWithSync({
    required String photoId,
    required String userId,
    String? imagePath,
    String? imageUrl,
    SyncStatus syncStatus = SyncStatus.pending,
  }) async {
    return await _db.insert(
      _keys.tableFavorites,
      {
        _keys.columnPhotoId: photoId,
        _keys.columnUserId: userId,
        _keys.columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
        _keys.columnImagePath: imagePath,
        _keys.columnImageUrl: imageUrl,
        _keys.columnSyncStatus: syncStatus.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertFavorite(String photoId, String userId) async {
    return await _db.insert(
      _keys.tableFavorites,
      {
        _keys.columnPhotoId: photoId,
        _keys.columnUserId: userId,
        _keys.columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
        _keys.columnSyncStatus: SyncStatus.pending.name,
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

  Future<List<MFavoritePhoto>> getPendingUploads(String userId) async {
    final result = await _db.query(
      _keys.tableFavorites,
      where: '${_keys.columnUserId} = ? AND ${_keys.columnSyncStatus} = ?',
      whereArgs: [userId, SyncStatus.pending.name],
      orderBy: '${_keys.columnCreatedAt} ASC',
    );
    return result.map((row) => MFavoritePhoto.fromLocalDb(row)).toList();
  }

  Future<bool> hasPendingUploads(String userId) async {
    final result = await _db.query(
      _keys.tableFavorites,
      where: '${_keys.columnUserId} = ? AND ${_keys.columnSyncStatus} = ?',
      whereArgs: [userId, SyncStatus.pending.name],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> clearAllFavorites() async {
    return await _db.delete(_keys.tableFavorites);
  }
}
