import 'package:abiya_translator/db/history_model.dart';
import 'package:abiya_translator/utils/logger.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  Future<Database> getDB() async {
    UserManager manager = GetIt.I<UserManager>();
    UserInfo? user = manager.getCurrentUser();
    String dbName = 'anonymous.db';
    if (user != null) {
      dbName = '${user.name}.db';
    }
    String path = join(await getDatabasesPath(), dbName);
    Logger.log('database path: $path');
    // Open the database and store the reference.
    var database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      path,
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        // "from" and "to" are quoted because they are SQL reserved keywords.
        return db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT, target TEXT, "from" TEXT, "to" TEXT, time INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // SQLite: use quoted names for reserved keywords; one ADD COLUMN per statement.
        await db.execute('ALTER TABLE history ADD COLUMN "from" TEXT');
        await db.execute('ALTER TABLE history ADD COLUMN "to" TEXT');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
    return database;
  }

  Future<void> insertHistory(History history) async {
    final db = await getDB();
    await db.insert(
      'history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<History>> historyList() async {
    final db = await getDB();

    final List<Map<String, Object?>> historyMaps =
        await db.query('history', orderBy: 'time DESC');

    return [
      for (final row in historyMaps)
        History(
            id: row['id'] as int,
            source: row['source'] as String,
            target: row['target'] as String,
            from: (row['from'] as String?) ?? '',
            to: (row['to'] as String?) ?? '',
            time: row['time'] as int),
    ];
  }

  Future<void> deleteHistory(int id) async {
    final db = await getDB();

    await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearHistory() async {
    final db = await getDB();

    await db.delete('history');
  }
}
