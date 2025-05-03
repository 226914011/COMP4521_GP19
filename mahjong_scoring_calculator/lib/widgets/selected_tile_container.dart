import 'package:flutter/material.dart';
import 'mahjong_icon_button.dart';

class SelectedTileContainer extends StatelessWidget {
  final List<String> selectedTiles;
  final Function(int) onRemove;

  const SelectedTileContainer({
    super.key,
    required this.selectedTiles,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final containerWidth = deviceSize.width * 0.8;
    final tileWidth = containerWidth / 18;

    return Container(
      width: containerWidth,
      height: deviceSize.height * 0.15,
      child: Row(
        children: List.generate(18, (index) {
          final hasTile = index < selectedTiles.length;
          return SizedBox(
            width: tileWidth,
            height: deviceSize.height * 0.15,
            child: hasTile
                ? MahjongIconButton(
                    tileType: selectedTiles[index],
                    onPressed: () => onRemove(index),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}