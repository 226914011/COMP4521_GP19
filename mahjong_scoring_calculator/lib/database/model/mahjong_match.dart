class MahjongMatch {
  final int? matchId;
  final DateTime? startTime;
  final DateTime? endTime;

  MahjongMatch({this.matchId, this.startTime, this.endTime});

  Map<String, dynamic> toMap() => {
    'match_id': matchId,
    'start_time': startTime?.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
  };

  factory MahjongMatch.fromMap(Map<String, dynamic> map) => MahjongMatch(
    matchId: map['match_id'],
    startTime: DateTime.parse(map['start_time']),
    endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
  );
}