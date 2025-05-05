import '../../enum/tile_type.dart';

class Tile {
  final int? tileId;
  final TileType tileType;

  Tile({
    this.tileId,
    required this.tileType,
  });

  Map<String, dynamic> toMap() => {
    'tile_id': tileId,
    'tile_type': tileType.toDbString,
  };

  factory Tile.fromMap(Map<String, dynamic> map) => Tile(
    tileId: map['tile_id'],
    tileType: TileType.values.firstWhere(
      (e) => e.toString().split('.').last == map['tile_type']
    ),
  );
}