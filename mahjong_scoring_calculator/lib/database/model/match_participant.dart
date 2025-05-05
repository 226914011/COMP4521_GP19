import '../../enum/seat_position.dart';

class MatchParticipant {
  final int? matchPartiId;
  final int userId;
  final int matchId;
  final SeatPosition? seatPosition;
  final bool? isDealer;

  MatchParticipant({
    this.matchPartiId,
    required this.userId,
    required this.matchId,
    this.seatPosition,
    this.isDealer,
  });

  Map<String, dynamic> toMap() => {
    'match_parti_id': matchPartiId,
    'user_id': userId,
    'match_id': matchId,
    'seat_position': seatPosition?.name,
    'is_dealer': isDealer,
  };

  factory MatchParticipant.fromMap(Map<String, dynamic> map) => MatchParticipant(
    matchPartiId: map['match_parti_id'],
    userId: map['user_id'],
    matchId: map['match_id'],
    seatPosition: map['seat_position'] != null 
        ? SeatPosition.values.firstWhere((e) => e.name == map['seat_position'])
        : null,
    isDealer: map['is_dealer'],
  );
}