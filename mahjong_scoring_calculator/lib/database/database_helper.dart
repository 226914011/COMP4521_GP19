import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

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

  // Get all matches from database
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    final db = await instance.database;
    // Get all matches, ordered by start time (most recent first)
    return await db.query(
      'Match',
      orderBy: 'start_time DESC',
    );
  }

  // Get participants for a specific match
  Future<List<Map<String, dynamic>>> getParticipantsByMatchId(
      int matchId) async {
    final db = await instance.database;
    // Join Match_Participant with User to get usernames
    final result = await db.rawQuery('''
      SELECT mp.*, u.username 
      FROM Match_Participant mp
      JOIN User u ON mp.user_id = u.user_id
      WHERE mp.match_id = ?
    ''', [matchId]);

    return result;
  }

  // Get game data for a specific match
  Future<List<Map<String, dynamic>>> getGamesByMatchId(int matchId) async {
    final db = await instance.database;
    // Get all games for the match, ordered by game_id
    return await db.query(
      'Game',
      where: 'match_id = ?',
      whereArgs: [matchId],
      orderBy: 'game_id ASC',
    );
  }

  // Get statistical summary for a specific player
  Future<Map<String, dynamic>> getPlayerStatistics(int userId) async {
    final db = await instance.database;
    final stats = <String, dynamic>{};

    // Total games played
    final gamesPlayed = Sqflite.firstIntValue(await db.rawQuery('''
    SELECT COUNT(DISTINCT m.match_id) 
    FROM Match_Participant mp
    JOIN Match m ON mp.match_id = m.match_id
    WHERE mp.user_id = ?
  ''', [userId]));
    stats['gamesPlayed'] = gamesPlayed ?? 0;

    // For all queries that previously used json_extract, we'll fetch the data
    // and process it in Dart instead

    // Get all games this player participated in
    final playerGames = await db.rawQuery('''
    SELECT g.*, mp.match_parti_id
    FROM Game g
    JOIN Match_Participant mp ON g.match_id = mp.match_id
    WHERE mp.user_id = ?
  ''', [userId]);

    // Calculate wins
    int wins = 0;
    double totalScore = 0;
    int maxScore = 0;

    for (final game in playerGames) {
      // Find player's position in the game
      final matchPartiId = game['match_parti_id'] as int;
      final participants = await db.query(
        'Match_Participant',
        where: 'match_id = ?',
        whereArgs: [game['match_id']],
        orderBy: 'match_parti_id ASC',
      );

      final playerIndex =
          participants.indexWhere((p) => p['match_parti_id'] == matchPartiId);

      // Check if this player won
      if (game['is_winner'] != null) {
        final List<dynamic> winners = jsonDecode(game['is_winner'] as String);
        if (playerIndex >= 0 &&
            playerIndex < winners.length &&
            winners[playerIndex] == true) {
          wins++;
        }
      }

      // Calculate scores
      if (game['points'] != null) {
        final List<dynamic> points = jsonDecode(game['points'] as String);
        if (playerIndex >= 0 && playerIndex < points.length) {
          final playerScore =
              points[playerIndex] is int ? points[playerIndex] as int : 0;
          totalScore += playerScore;
          if (playerScore > maxScore) {
            maxScore = playerScore;
          }
        }
      }
    }

    stats['wins'] = wins;

    // Win rate
    stats['winRate'] = gamesPlayed! > 0 ? (wins / gamesPlayed * 100) : 0;

    // Average score
    stats['averageScore'] =
        playerGames.isNotEmpty ? totalScore / playerGames.length : 0;

    // Highest score
    stats['highestScore'] = maxScore;

    return stats;
  }

  // Get match history with details
  Future<List<Map<String, dynamic>>> getMatchHistory(
      {int? limit, int? offset}) async {
    final db = await instance.database;

    // Get matches with additional summary data
    return await db.rawQuery('''
    SELECT 
      m.match_id, 
      m.start_time, 
      m.end_time,
      (
        SELECT COUNT(DISTINCT user_id) 
        FROM Match_Participant 
        WHERE match_id = m.match_id
      ) as player_count,
      (
        SELECT username 
        FROM User 
        WHERE user_id = (
          SELECT user_id 
          FROM Match_Participant 
          WHERE match_id = m.match_id AND is_dealer = 1 
          LIMIT 1
        )
      ) as dealer_name
    FROM Match m
    ORDER BY m.start_time DESC
    ${limit != null ? 'LIMIT $limit' : ''}
    ${offset != null ? 'OFFSET $offset' : ''}
  ''');
  }

  // Get detailed game results for a specific match
  Future<Map<String, dynamic>> getMatchDetails(int matchId) async {
    final db = await instance.database;
    final result = <String, dynamic>{};

    // Get basic match info
    final matchInfo = await db.query(
      'Match',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );

    if (matchInfo.isEmpty) {
      return {'error': 'Match not found'};
    }

    result['matchInfo'] = matchInfo.first;

    // Get participants
    final participants = await getParticipantsByMatchId(matchId);
    result['participants'] = participants;

    // Get games in this match
    final games = await getGamesByMatchId(matchId);
    result['games'] = games;

    // Calculate final scores
    final finalScores = <String, dynamic>{};
    for (final participant in participants) {
      final userId = participant['user_id'];
      final username = participant['username'];

      if (games.isNotEmpty && games.last['points'] != null) {
        final int playerIndex =
            participants.indexWhere((p) => p['user_id'] == userId);
        final List<dynamic> points = jsonDecode(games.last['points']);
        finalScores[username] =
            playerIndex < points.length ? points[playerIndex] : 0;
      } else {
        finalScores[username] = 0;
      }
    }

    result['finalScores'] = finalScores;

    return result;
  }

  // Add to DatabaseHelper class
  Future<int> updateMatch(int matchId, {DateTime? endTime}) async {
    final db = await instance.database;
    return await db.update(
      'Match',
      {
        'end_time': endTime?.toIso8601String(),
      },
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
  }

  // Helper methods
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
