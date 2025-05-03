import 'package:flutter/material.dart';
import 'mahjong_icon_button.dart';

class MahjongTileContainer extends StatelessWidget {
  final double width;
  final Function(String) onTileSelected;

  const MahjongTileContainer({
    super.key,
    required this.width,
    required this.onTileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = constraints.maxWidth / 12;
          final tileHeight = tileWidth * (128 / 82);
          final tileTypes = [
            _buildSuitTiles('bamboo'),
            _buildSuitTiles('man'),
            _buildSuitTiles('pin'),
            _buildWindTiles(),
            _buildDragonTiles(),
          ].expand((x) => x).toList();

          return SizedBox(
            height: tileHeight * 3,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 12,
                childAspectRatio: 82/128,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: tileTypes.length,
              itemBuilder: (context, index) => SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: MahjongIconButton(
                  tileType: tileTypes[index].$1,
                  number: tileTypes[index].$2,
                  onPressed: () => onTileSelected(tileTypes[index].$3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<(String, int?, String)> _buildSuitTiles(String suit) {
    return List.generate(9, (i) => (
      suit, 
      i+1, 
      '$suit${i+1}'
    ));
  }

  List<(String, int?, String)> _buildWindTiles() {
    return ['east', 'south', 'west', 'north']
      .map((wind) => ('wind-$wind', null, 'wind-$wind'))
      .toList();
  }

  List<(String, int?, String)> _buildDragonTiles() {
    return ['chun', 'green', 'haku']
      .map((dragon) => ('dragon-$dragon', null, 'dragon-$dragon'))
      .toList();
  }
}