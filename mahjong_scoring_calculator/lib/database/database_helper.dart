import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../enum/seat_position.dart';
import '../enum/tile_type.dart';
import 'model/fan.dart';
import 'model/game.dart';
import 'model/mahjong_match.dart';
import 'model/match_participant.dart';
import 'model/tile.dart';
import 'model/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mahjong.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final docDir = await getApplicationDocumentsDirectory();
    final path = join(docDir.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE User (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Match (
        match_id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT,
        end_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Match_Participant (
        match_parti_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        match_id INTEGER NOT NULL,
        seat_position TEXT,
        is_dealer INTEGER,
        FOREIGN KEY (user_id) REFERENCES User (user_id),
        FOREIGN KEY (match_id) REFERENCES Match (match_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Game (
        game_id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        points TEXT,
        is_winner TEXT,
        winning_tile TEXT,
        FOREIGN KEY (match_id) REFERENCES Match (match_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Fans (
        fan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        fan_name TEXT NOT NULL,
        fan_value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Tiles (
        tile_id INTEGER PRIMARY KEY AUTOINCREMENT,
        tile_type TEXT NOT NULL
      )
    ''');

    await _initFans(db);
    await _initTiles(db);
  }

  Future<void> _initFans(Database db) async {
    final fans = [
      {'fan_name': 'Big Three Dragons', 'fan_value': 88},
      {'fan_name': 'Four Concealed Pungs', 'fan_value': 64},
      {'fan_name': 'All Honors', 'fan_value': 32},
      {'fan_name': 'Seven Pairs', 'fan_value': 24},
    ];
    
    for (final fan in fans) {
      await db.insert('Fans', fan);
    }
  }

  Future<void> _initTiles(Database db) async {
    for (final tileType in TileType.values) {
      await db.insert('Tiles', {'tile_type': tileType.toDbString});
    }
  }

  // User operations
  Future<int> insertUser(String username) async {
    return _insertUser(User(username: username));
  }

  Future<int> _insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('User', user.toMap());
  }

  Future<int> deleteUser(int userId) async {
    final db = await instance.database;
    return await db.delete(
      'User',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final maps = await db.query('User');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Match operations
  Future<int> insertMatch({DateTime? startTime, DateTime? endTime}) async {
    return _insertMatch(MahjongMatch(
      startTime: startTime,
      endTime: endTime,
    ));
  }

  Future<int> _insertMatch(MahjongMatch match) async {
    final db = await instance.database;
    return await db.insert('Match', match.toMap());
  }

  // MatchParticipant operations
  Future<int> insertParticipant({
    required int userId,
    required int matchId,
    SeatPosition? seatPosition,
    bool? isDealer,
  }) async {
    return _insertParticipant(MatchParticipant(
      userId: userId,
      matchId: matchId,
      seatPosition: seatPosition,
      isDealer: isDealer,
    ));
  }

  Future<int> _insertParticipant(MatchParticipant participant) async {
    final db = await instance.database;
    return await db.insert('Match_Participant', participant.toMap());
  }

  // Game operations
  Future<int> insertGame({
    required int matchId,
    List<int>? points,
    List<bool>? isWinner,
    List<List<String>?>? winningTile,
  }) async {
    return _insertGame(Game(
      matchId: matchId,
      points: points,
      isWinner: isWinner,
      winningTile: winningTile,
    ));
  }

  Future<int> _insertGame(Game game) async {
    final db = await instance.database;
    return await db.insert('Game', game.toMap());
  }

  // Read-only operations for Fans and Tiles
  Future<List<Fan>> getAllFans() async {
    final db = await instance.database;
    final maps = await db.query('Fans');
    return maps.map((map) => Fan.fromMap(map)).toList();
  }

  Future<List<Tile>> getAllTiles() async {
    final db = await instance.database;
    final maps = await db.query('Tiles');
    return maps.map((map) => Tile.fromMap(map)).toList();
  }

  // Helper methods
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}