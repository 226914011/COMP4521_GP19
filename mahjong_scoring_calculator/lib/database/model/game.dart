import 'dart:convert';

class Game {
  final int? gameId;
  final int matchId;
  final List<int>? points;
  final List<bool>? isWinner;
  final List<List<String>?>? winningTile;

  Game({
    this.gameId,
    required this.matchId,
    this.points,
    this.isWinner,
    this.winningTile,
  });

  Map<String, dynamic> toMap() => {
    'game_id': gameId,
    'match_id': matchId,
    'points': jsonEncode(points),
    'is_winner': jsonEncode(isWinner),
    'winning_tile': jsonEncode(winningTile),
  };

  factory Game.fromMap(Map<String, dynamic> map) => Game(
    gameId: map['game_id'],
    matchId: map['match_id'],
    points: map['points'] != null 
        ? List<int>.from(jsonDecode(map['points'])) 
        : null,
    isWinner: map['is_winner'] != null
        ? List<bool>.from(jsonDecode(map['is_winner']))
        : null,
    winningTile: map['winning_tile'] != null
        ? List<List<String>?>.from(jsonDecode(map['winning_tile'])
            .map((e) => e != null ? List<String>.from(e) : null))
        : null,
  );
}