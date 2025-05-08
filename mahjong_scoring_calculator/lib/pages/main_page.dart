import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math'; // Add this import for Random

import '../widgets/custom_bottom_bar.dart';
import '../widgets/player_container.dart';
import '../widgets/custom_button.dart';
import '../widgets/player_selection_dialog.dart';
import 'scanning_page.dart';
import 'test_page.dart';
import 'winning_tile_page.dart';
import '../utils/api_test_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool gameStarted = false;
  final List<bool> hasPlayers = [false, false, false, false];
  final playerNames = ['', '', '', ''];
  final List<int> playerIds = [-1, -1, -1, -1];
  final scores = [0, 0, 0, 0];
  final List<String> winds = ['East', 'South', 'West', 'North'];
  int currentWindIndex = 0;

  // --- API Testing State & Handler ---
  final ApiTestHandler _apiTestHandler =
      ApiTestHandler(); // Instance of the handler

  // State for Melds API Test
  Map<String, dynamic>? _meldApiResult;
  String? _meldApiError;
  bool _isMeldLoading = false;

  // State for Raw Tiles API Test
  Map<String, dynamic>? _rawTileApiResult;
  String? _rawTileApiError;
  bool _isRawTileLoading = false;
  // --- End API Testing State ---

  // --- Existing Game Logic Methods ---
  void _checkStartGame() {
    if (hasPlayers.every((player) => player)) {
      setState(() {
        gameStarted = true;
        // Randomly select initial dealer position (0-3)
        dealerPosition = Random().nextInt(4);
        currentWindIndex = 0; // Start with East wind
        handsPlayedInRound = 1;
        isNewRound = true;
      });
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
      playerIds
          .asMap()
          .forEach((index, id) => _resetPlayer(index)); // Reset all players
      // Clear API test results on game reset
      _meldApiResult = null;
      _meldApiError = null;
      _rawTileApiResult = null;
      _rawTileApiError = null;
    });
  }

  // --- API Test Execution Methods ---
  Future<void> _runMeldTest() async {
    if (_isMeldLoading) return; // Prevent double taps
    setState(() {
      _isMeldLoading = true;
      _meldApiResult = null; // Clear previous results
      _meldApiError = null;
    });

    try {
      final result = await _apiTestHandler.executeMeldTest(); // Call handler
      if (!mounted) return; // Check if widget is still alive after await
      setState(() {
        _meldApiResult = result;
      });
      _showSnackbar('Meld API Success!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = "Meld Test Failed: ${e.toString()}";
      setState(() {
        _meldApiError = errorMessage;
      });
      _showSnackbar(errorMessage, Colors.red);
    } finally {
      if (!mounted) return;
      setState(() {
        _isMeldLoading = false;
      }); // Ensure loading stops
    }
  }

  Future<void> _runRawTileTest() async {
    if (_isRawTileLoading) return; // Prevent double taps
    setState(() {
      _isRawTileLoading = true;
      _rawTileApiResult = null; // Clear previous results
      _rawTileApiError = null;
    });

    try {
      final result = await _apiTestHandler.executeRawTileTest(); // Call handler
      if (!mounted) return;
      setState(() {
        _rawTileApiResult = result;
      });
      _showSnackbar('Raw Tile API Success!', Colors.blue);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = "Raw Tile Test Failed: ${e.toString()}";
      setState(() {
        _rawTileApiError = errorMessage;
      });
      _showSnackbar(errorMessage, Colors.orange);
    } finally {
      if (!mounted) return;
      setState(() {
        _isRawTileLoading = false;
      }); // Ensure loading stops
    }
  }

  // --- Snackbar Helper Method ---
  void _showSnackbar(String message, Color backgroundColor) {
    if (mounted) {
      // Check if the widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3), // Adjust as needed
        ),
      );
    }
  }

  // --- UI Helper ---
  Widget _buildGridCell(Widget child) {
    return Expanded(
      child: Center(child: child),
    );
  }

  void _resetPlayer(int index) {
    setState(() {
      hasPlayers[index] = false;
      playerNames[index] = '';
      playerIds[index] = -1;
      scores[index] = 0;
    });
  }

  void _showPlayerSelectionDialog(int playerIndex) {
    showDialog(
      context: context,
      builder: (context) => PlayerSelectionDialog(
        onPlayerSelected: (name, userId) {
          setState(() {
            hasPlayers[playerIndex] = true;
            playerNames[playerIndex] = name;
            playerIds[playerIndex] = userId;
            scores[playerIndex] = 0;
          });
        },
        existingPlayerIds: playerIds.where((id) => id != -1).toList(),
      ),
    );
  }

  void _showDebugMenu() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Debug Menu'),
        children: [
          _buildDebugOption(
              'Winning Tiles Page', WinningTilePage(playerNames: playerNames)),
          _buildDebugOption('Scanning Page', const ScanningPage()),
          _buildDebugOption('API Test Page', const TestPage()),
        ],
      ),
    );
  }

  ListTile _buildDebugOption(String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the dialog
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  // Add these variables to your _MainPageState class
  int dealerPosition = 0; // 0 = East player, 1 = South, etc.
  int handsPlayedInRound = 1;
  bool isNewRound = true;

  // Update the wind indicator to show actual wind
  Widget _buildWindIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Prevailing wind: ${winds[currentWindIndex]}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Dealer: ${playerNames[dealerPosition]}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Hands in round: $handsPlayedInRound/4',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final deviceSize =
        MediaQuery.of(context).size; // Keep if CustomButton uses it

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Row 0
            Expanded(
              child: Row(
                children: [
                  // (0,0) - API Test Buttons & Results
                  _buildGridCell(SingleChildScrollView(
                    // Use ScrollView for long results
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Meld Test Button & Result Display
                          ElevatedButton(
                            onPressed: _isMeldLoading ? null : _runMeldTest,
                            child: _isMeldLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Test Melds API'),
                          ),
                          // Conditional display for Meld results/errors
                          if (_meldApiResult != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Meld OK: ${jsonEncode(_meldApiResult)}', // Display JSON result
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (_meldApiError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _meldApiError!, // Display error message
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          const SizedBox(height: 15), // Spacer

                          // Raw Tile Test Button & Result Display
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent),
                            onPressed:
                                _isRawTileLoading ? null : _runRawTileTest,
                            child: _isRawTileLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Test Raw Tiles API'),
                          ),
                          // Conditional display for Raw Tile results/errors
                          if (_rawTileApiResult != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Raw OK: ${jsonEncode(_rawTileApiResult)}', // Display JSON result
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.blue),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (_rawTileApiError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _rawTileApiError!, // Display error message
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.orange),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),

                  // (0,1) Player at north
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[3],
                    gameStarted: gameStarted,
                    playerName: playerNames[3],
                    playerScore: scores[3],
                    onAdd: () => _showPlayerSelectionDialog(3),
                    onReset: () => _resetPlayer(3),
                  )),

                  // (0,2)
                  _buildGridCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (gameStarted)
                          IconButton(
                            // icon: const Icon(Icons.add_box), // Original
                            icon: const Icon(Icons.restart_alt), // Suggestion
                            tooltip: "Reset Game",
                            onPressed: _resetGame,
                          ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: "Save Game",
                          onPressed: _saveAndLoadGame, // Placeholder
                        ),
                        IconButton(
                          icon: const Icon(Icons.history),
                          tooltip: "Load History",
                          onPressed: _loadGameHistory, // Placeholder
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
                  // (1,0) Player at west
                  _buildGridCell(PlayerContainer(
                    gameStarted: gameStarted,
                    hasPlayer: hasPlayers[2],
                    playerName: playerNames[2],
                    playerScore: scores[2],
                    onAdd: () => _showPlayerSelectionDialog(2),
                    onReset: () => _resetPlayer(2),
                  )),

                  // (1,1)
                  _buildGridCell(
                    gameStarted
                        ? _buildWindIndicator()
                        : CustomButton(
                            text: 'Start Game',
                            width: deviceSize.width * 0.2,
                            height: deviceSize.height * 0.15,
                            fontSize: 18,
                            borderRadius: deviceSize.width * 0.1,
                            onPressed: _checkStartGame,
                          ),
                  ),

                  // (1,2) Player at east
                  _buildGridCell(PlayerContainer(
                    gameStarted: gameStarted,
                    hasPlayer: hasPlayers[0],
                    playerName: playerNames[0],
                    playerScore: scores[0],
                    onAdd: () => _showPlayerSelectionDialog(0),
                    onReset: () => _resetPlayer(0),
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

                  // (2,1) Player at south
                  _buildGridCell(PlayerContainer(
                    gameStarted: gameStarted,
                    hasPlayer: hasPlayers[1],
                    playerName: playerNames[1],
                    playerScore: scores[1],
                    onAdd: () => _showPlayerSelectionDialog(1),
                    onReset: () => _resetPlayer(1),
                  )),

                  // (2,2)
                  _buildGridCell(
                    gameStarted
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomButton(text: 'Draw', onPressed: _draw),
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
      bottomNavigationBar: CustomBottomBar(
        onDebugPressed: _showDebugMenu,
      ),
    );
  }

  void _saveAndLoadGame() {
    // Your save game implementation
  }

  void _loadGameHistory() {
    // Your load game implementation
  }

  void _draw() {
    setState(() {
      // Store the current dealer's name before rotation
      final currentDealerName = playerNames[dealerPosition];

      // Rotate the dealership after a draw
      _rotateDealership();

      // Show dialog confirming the draw and dealer change
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Round Ended in Draw'),
          content: Text(
              'The round has ended in a draw. Dealer changes from $currentDealerName to ${playerNames[dealerPosition]}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Show dealer change notification
      _showSnackbar("Draw - Dealer changed to ${playerNames[dealerPosition]}",
          Colors.blue);
    });
  }

  void _win() {
    // Navigate to the winning tile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WinningTilePage(playerNames: playerNames),
      ),
    ).then((result) {
      // Handle the result when returning from the winning tile page
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          // Update scores based on win result
          if (result.containsKey('winnerIndex') &&
              result.containsKey('points')) {
            final winnerIndex = result['winnerIndex'] as int;
            final points = result['points'] as int;

            // Update winner's score
            scores[winnerIndex] += points;

            // Update other players' scores (losers pay points)
            for (int i = 0; i < scores.length; i++) {
              if (i != winnerIndex) {
                // Basic implementation - each player pays equal amount
                scores[i] -= (points ~/ 3);
              }
            }

            // If current dealer won, they keep the dealership (no rotation)
            // Otherwise, rotate the dealership
            if (winnerIndex != dealerPosition) {
              _rotateDealership();
            } else {
              // Dealer won - show a message
              _showSnackbar("${playerNames[dealerPosition]} keeps dealership",
                  Colors.green);
            }
          }
        });
      }
    });
  }

  // Add this method to handle dealer rotation
  void _rotateDealership() {
    setState(() {
      // Rotate dealer position counter-clockwise
      dealerPosition = (dealerPosition + 1) % 4;
      handsPlayedInRound++;

      // Check if we've completed a round (all players have been dealer)
      if (handsPlayedInRound >= 4) {
        handsPlayedInRound = 0;
        currentWindIndex = (currentWindIndex + 1) % winds.length;
        isNewRound = true;

        // Show message for new round
        _showSnackbar(
            "New round: ${winds[currentWindIndex]} wind", Colors.amber);
      }
    });
  }

  // Add this helper method to calculate seat wind for a player
  String getSeatWind(int playerPosition) {
    // Calculate relative position from dealer
    // (dealer + playerPosition) % 4 gives the absolute position
    // winds[(4 + playerPosition - dealerPosition) % 4] gives the wind relative to dealer
    return winds[(4 + playerPosition - dealerPosition) % 4];
  }
}
