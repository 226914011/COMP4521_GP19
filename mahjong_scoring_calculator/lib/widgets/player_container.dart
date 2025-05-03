import 'package:flutter/material.dart';

class PlayerContainer extends StatefulWidget {
  const PlayerContainer({super.key});

  @override
  State<PlayerContainer> createState() => _PlayerContainerState();
}

class _PlayerContainerState extends State<PlayerContainer> {
  bool hasPlayer = false;
  String playerName = 'Frankie';
  int score = 4521;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final containerWidth = deviceSize.width * 0.25;
    final containerHeight = deviceSize.height * 0.25;

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
        icon: const Icon(Icons.add_circle, size: 50),
        onPressed: () => setState(() => hasPlayer = true),
      ),
    );
  }

  Widget _buildPlayerView() {
    return Stack(
      children: [
        // Player Name
        Positioned(
          left: 8,
          top: 8,
          child: Text(
            playerName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Score
        Center(
          child: Text(
            score.toString(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
        // Reset Button
        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            icon: const Icon(Icons.restart_alt, size: 24),
            onPressed: () => setState(() => hasPlayer = false),
          ),
        ),
      ],
    );
  }
}