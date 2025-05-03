import 'package:flutter/material.dart';

class MahjongIconButton extends StatelessWidget {
  final String tileType;
  final int? number;
  final VoidCallback onPressed;

  const MahjongIconButton({
    super.key,
    required this.tileType,
    this.number,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = number != null ? '$tileType$number.png' : '$tileType.png';

    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        'assets/mahjong_tiles/$fileName',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}