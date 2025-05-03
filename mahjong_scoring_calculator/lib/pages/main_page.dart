import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/player_container.dart';
import '../widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool gameStarted = false;
  final List<bool> hasPlayers = [false, false, false, false];
  final playerNames = ['', '', '', ''];
  final scores = [0, 0, 0, 0];

  void _checkStartGame() {
    if (hasPlayers.every((player) => player)) {
      setState(() => gameStarted = true);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Insufficient players to start the game.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  void _resetGame() {
    setState(() {
      gameStarted = false;
      hasPlayers.fillRange(0, 4, false);
    });
  }

  Widget _buildGridCell(Widget child) {
    return Expanded(
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(child:
        Column(
          children: [
            // Row 0
            Expanded(
              child: Row(
                children: [
                  // (0,0)
                  _buildGridCell(const SizedBox.shrink()),

                  // (0,1)
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[0],
                    onAdd: () => setState(() => hasPlayers[0] = true),
                    onReset: () => setState(() => hasPlayers[0] = false),
                  )),

                  // (0,2)
                  _buildGridCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (gameStarted)
                          IconButton(
                            icon: const Icon(Icons.add_box),
                            onPressed: _resetGame,
                          ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveAndLoadGame,
                        ),
                        IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: _loadGameHistory,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Row 1
            Expanded(
              child: Row(
                children: [
                  // (1,0)
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[1],
                    onAdd: () => setState(() => hasPlayers[1] = true),
                    onReset: () => setState(() => hasPlayers[1] = false),
                  )),

                  // (1,1)
                  _buildGridCell(
                    gameStarted
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text('Prevalent wind: East',
                                style: TextStyle(fontSize: 16)),
                          )
                        : CustomButton(
                            text: 'Start Game',
                            width: deviceSize.width * 0.2,
                            height: deviceSize.height * 0.15,
                            fontSize: 18,
                            borderRadius: deviceSize.width * 0.1,
                            onPressed: _checkStartGame,
                          ),
                  ),

                  // (1,2)
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[2],
                    onAdd: () => setState(() => hasPlayers[2] = true),
                    onReset: () => setState(() => hasPlayers[2] = false),
                  )),
                ],
              ),
            ),

            // Row 2
            Expanded(
              child: Row(
                children: [
                  // (2,0)
                  _buildGridCell(const SizedBox.shrink()),

                  // (2,1)
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[3],
                    onAdd: () => setState(() => hasPlayers[3] = true),
                    onReset: () => setState(() => hasPlayers[3] = false),
                  )),

                  // (2,2)
                  _buildGridCell(
                    gameStarted
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(text: 'Draw', onPressed: _draw),
                              const SizedBox(height: 5),
                              CustomButton(text: 'Win', onPressed: _win),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  static void _saveAndLoadGame() {}
  static void _loadGameHistory() {}
  static void _draw() {}
  static void _win() {}
}