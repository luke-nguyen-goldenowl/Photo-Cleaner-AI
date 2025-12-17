import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class PhotoDatabaseHelper {
  static const String _databaseName = 'photo_app.db';
  static const int _databaseVersion = 1;
  static const String tableFavorites = 'favorites';
  static const String columnPhotoId = 'photo_id';
  static const String columnUserId = 'user_id';
  static const String columnCreatedAt = 'created_at';

  PhotoDatabaseHelper._privateConstructor();
  static final PhotoDatabaseHelper instance =
      PhotoDatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFavorites (
        $columnPhotoId TEXT NOT NULL,
        $columnUserId TEXT NOT NULL,
        $columnCreatedAt INTEGER NOT NULL,
        PRIMARY KEY ($columnPhotoId, $columnUserId)
      )
    ''');
  }

  Future<int> insertFavorite(String photoId, String userId) async {
    final db = await database;
    return await db.insert(
      tableFavorites,
      {
        columnPhotoId: photoId,
        columnUserId: userId,
        columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteFavorite(String photoId, String userId) async {
    final db = await database;
    return await db.delete(
      tableFavorites,
      where: '$columnPhotoId = ? AND $columnUserId = ?',
      whereArgs: [photoId, userId],
    );
  }

  Future<bool> isFavorite(String photoId, String userId) async {
    final db = await database;
    final result = await db.query(
      tableFavorites,
      where: '$columnPhotoId = ? AND $columnUserId = ?',
      whereArgs: [photoId, userId],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAllFavorites(String userId) async {
    final db = await database;
    final result = await db.query(
      tableFavorites,
      where: '$columnUserId = ?',
      whereArgs: [userId],
      orderBy: '$columnCreatedAt DESC',
    );
    return result.map((row) => row[columnPhotoId] as String).toList();
  }

  Future<int> clearAllFavorites() async {
    final db = await database;
    return await db.delete(tableFavorites);
  }
}
