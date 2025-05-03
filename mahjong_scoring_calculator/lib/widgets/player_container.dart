import 'package:flutter/material.dart';

class PlayerContainer extends StatelessWidget {
  final bool hasPlayer;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  const PlayerContainer({
    super.key,
    required this.hasPlayer,
    required this.onAdd,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final containerWidth = deviceSize.width * 0.25;
    final containerHeight = deviceSize.height * 0.22;

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasPlayer ? _buildPlayerView() : _buildAddButton(),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.add_circle, size: 36),
        onPressed: onAdd,
      ),
    );
  }

  Widget _buildPlayerView() {
    return Stack(
      children: [
        Positioned(
          left: 10,
          top: 10,
          child: Text(
            'Frankie',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Center(
          child: Text(
            '4521',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: IconButton(
            icon: const Icon(Icons.restart_alt, size: 15),
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}