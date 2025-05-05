enum TileType {
  bamboo1, bamboo2, bamboo3, bamboo4, bamboo5, bamboo6, bamboo7, bamboo8, bamboo9,
  man1, man2, man3, man4, man5, man6, man7, man8, man9,
  pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8, pin9,
  windEast, windSouth, windWest, windNorth,
  dragonChun, dragonGreen, dragonHaku
}

extension TileTypeExtension on TileType {
  String get toDbString {
    switch (this) {
      case TileType.windEast:
        return 'wind-east';
      case TileType.windSouth:
        return 'wind-south';
      case TileType.windWest:
        return 'wind-west';
      case TileType.windNorth:
        return 'wind-north';
      case TileType.dragonChun:
        return 'dragon-chun';
      case TileType.dragonGreen:
        return 'dragon-green';
      case TileType.dragonHaku:
        return 'dragon-haku';
      default:
        return toString().split('.').last;
    }
  }
}