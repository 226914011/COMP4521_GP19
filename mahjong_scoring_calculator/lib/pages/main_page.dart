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
import '../database/database_helper.dart';
import '../enum/seat_position.dart';
import 'history_page.dart'; // Import the history page

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
  int _currentMatchId = -1;
  List<String>? _lastWinningTiles;
  int dealerPosition = 0; // 0 = East player, 1 = South, etc.
  int handsPlayedInRound = 1;
  bool isNewRound = true;

  // --- API Testing State & Handler ---
  final ApiTestHandler _apiTestHandler =
      ApiTestHandler(); // Instance of the handler

  // State for Melds API Test
  // Map<String, dynamic>? _meldApiResult;
  // String? _meldApiError;
  // bool _isMeldLoading = false;

  // State for Raw Tiles API Test
  Map<String, dynamic>? _rawTileApiResult;
  String? _rawTileApiError;
  bool _isRawTileLoading = false;
  // --- End API Testing State ---

  // --- Game State ---
  Future<void> _checkStartGame() async {
    if (hasPlayers.every((player) => player)) {
      // Get the match ID first, then update state
      final matchId = await _createNewMatchId();
      setState(() {
        gameStarted = true;
        // Randomly select initial dealer position (0-3)
        dealerPosition = Random().nextInt(4);
        currentWindIndex = 0; // Start with East wind
        handsPlayedInRound = 1;
        isNewRound = true;
        _currentMatchId = matchId;
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

  void _resetGame() async {
    // If we have an active match, update its end time
    if (_currentMatchId != -1) {
      try {
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.updateMatch(
          _currentMatchId,
          endTime: DateTime.now(),
        );
      } catch (e) {
        _showSnackbar('Failed to complete match record: $e', Colors.orange);
      }
    }

    setState(() {
      gameStarted = false;
      playerIds
          .asMap()
          .forEach((index, id) => _resetPlayer(index)); // Reset all players
      // Clear API test results on game reset
      // _meldApiResult = null;
      // _meldApiError = null;
      _rawTileApiResult = null;
      _rawTileApiError = null;
      // Reset match tracking
      _currentMatchId = -1;
      _lastWinningTiles = null;
    });
  }

  // --- API Test Execution Methods ---
  // Future<void> _runMeldTest() async {
  //   if (_isMeldLoading) return; // Prevent double taps
  //   setState(() {
  //     _isMeldLoading = true;
  //     _meldApiResult = null; // Clear previous results
  //     _meldApiError = null;
  //   });

  //   try {
  //     final result = await _apiTestHandler.executeMeldTest(); // Call handler
  //     if (!mounted) return; // Check if widget is still alive after await
  //     setState(() {
  //       _meldApiResult = result;
  //     });
  //     _showSnackbar('Meld API Success!', Colors.green);
  //   } catch (e) {
  //     if (!mounted) return;
  //     final errorMessage = "Meld Test Failed: ${e.toString()}";
  //     setState(() {
  //       _meldApiError = errorMessage;
  //     });
  //     _showSnackbar(errorMessage, Colors.red);
  //   } finally {
  //     if (!mounted) return;
  //     setState(() {
  //       _isMeldLoading = false;
  //     }); // Ensure loading stops
  //   }
  // }

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
                          // ElevatedButton(
                          //   onPressed: _isMeldLoading ? null : _runMeldTest,
                          //   child: _isMeldLoading
                          //       ? const SizedBox(
                          //           width: 16,
                          //           height: 16,
                          //           child: CircularProgressIndicator(
                          //               strokeWidth: 2))
                          //       : const Text('Test Melds API'),
                          // ),
                          // // Conditional display for Meld results/errors
                          // if (_meldApiResult != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 4.0),
                          //     child: Text(
                          //       'Meld OK: ${jsonEncode(_meldApiResult)}', // Display JSON result
                          //       style: const TextStyle(
                          //           fontSize: 10, color: Colors.green),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          // if (_meldApiError != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 4.0),
                          //     child: Text(
                          //       _meldApiError!, // Display error message
                          //       style: const TextStyle(
                          //           fontSize: 10, color: Colors.red),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),

                          // const SizedBox(height: 15), // Spacer

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
                          onPressed: _saveGame,
                        ),
                        IconButton(
                          icon: const Icon(Icons.history),
                          tooltip: "Load History",
                          onPressed: _loadGameHistory,
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart),
                          tooltip: "View History",
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryPage()),
                          ),
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

  // Create new match ID
  Future<int> _createNewMatchId() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.insertMatch(
      startTime: DateTime.now(),
      // Leave endTime null since game is in progress
    );
  }

  // --- Save Game Methods ---
  Future<void> _saveGame() async {
    // Only allow saving if a game is in progress
    if (!gameStarted) {
      _showSnackbar('No active game to save', Colors.orange);
      return;
    }

    // Check if all players are set
    if (!hasPlayers.every((hasPlayer) => hasPlayer)) {
      _showSnackbar(
          'Cannot save: All player positions must be filled', Colors.red);
      return;
    }

    try {
      final dbHelper = DatabaseHelper.instance;

      // 1. Create a new match record if one doesn't exist
      if (_currentMatchId == -1) {
        final now = DateTime.now();
        _currentMatchId = await dbHelper.insertMatch(startTime: now);
      }

      // 2. Add all players as match participants
      for (int i = 0; i < playerIds.length; i++) {
        // Skip if player ID is not valid
        if (playerIds[i] == -1) continue;

        // Get the seat position for this player index
        final seatPosition = getSeatWind(i);

        await dbHelper.insertParticipant(
          userId: playerIds[i],
          matchId: _currentMatchId,
          seatPosition: _seatPositionFromString(seatPosition),
          isDealer: i == dealerPosition, // Set dealer flag
        );
      }

      // 3. Save current game state (points, etc.)
      // Convert scores array to string for storage
      final pointsString = jsonEncode(scores);

      // Create an array to track who won the current game
      final List<bool> winners = List.filled(4, false);

      await dbHelper.insertGame(
        matchId: _currentMatchId,
        points: scores,
        isWinner: winners, // No winner for saved game in progress
        // Optional: Include other game state if needed
      );

      // Show success message
      _showSnackbar(
          'Game saved successfully! Match ID: $_currentMatchId', Colors.green);

      // Optional: Offer to continue or start a new game
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Game Saved'),
            content: Text(
                'Your game has been saved with Match ID: $_currentMatchId. You can load it later from the history.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continue Playing'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame(); // Reset for a new game
                },
                child: const Text('Start New Game'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle database errors
      _showSnackbar('Error saving game: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _loadGameHistory() async {
    final dbHelper = DatabaseHelper.instance;

    try {
      // 1. Get all saved matches with their start times
      final matches = await dbHelper.getAllMatches();

      if (matches.isEmpty) {
        _showSnackbar('No saved games found', Colors.orange);
        return;
      }

      // 2. Show dialog to select a match
      if (!mounted) return;
      final selectedMatch = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Load Saved Game'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final DateTime startTime = DateTime.parse(match['start_time']);
                final String formattedDate =
                    '${startTime.year}/${startTime.month}/${startTime.day} ${startTime.hour}:${startTime.minute}';

                return ListTile(
                  title: Text('Match ID: ${match['match_id']}'),
                  subtitle: Text('Date: $formattedDate'),
                  onTap: () => Navigator.pop(context, match),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedMatch == null) return;

      // 3. Load participants for the selected match
      final participants =
          await dbHelper.getParticipantsByMatchId(selectedMatch['match_id']);

      if (participants.isEmpty) {
        _showSnackbar('No player data found for this match', Colors.orange);
        return;
      }

      // 4. Load game data (scores, etc)
      final games = await dbHelper.getGamesByMatchId(selectedMatch['match_id']);

      if (games.isEmpty) {
        _showSnackbar('No game data found for this match', Colors.orange);
        return;
      }

      // 5. Update the game state with loaded data
      setState(() {
        // Reset current game state
        gameStarted = true;

        // Set current match ID
        _currentMatchId = selectedMatch['match_id'];

        // Initialize arrays
        final newPlayerNames = List<String>.filled(4, '');
        final newPlayerIds = List<int>.filled(4, -1);
        final newHasPlayers = List<bool>.filled(4, false);

        // Set players based on their seat positions
        for (final participant in participants) {
          final seatPosition = participant['seat_position'].toString();
          int playerIndex;

          // Convert seat position string to index (East=0, South=1, West=2, North=3)
          switch (seatPosition.toLowerCase()) {
            case 'east':
              playerIndex = 0;
              break;
            case 'south':
              playerIndex = 1;
              break;
            case 'west':
              playerIndex = 2;
              break;
            case 'north':
              playerIndex = 3;
              break;
            default:
              playerIndex = 0;
          }

          newPlayerNames[playerIndex] =
              participant['username'] ?? 'Player ${playerIndex + 1}';
          newPlayerIds[playerIndex] = participant['user_id'] ?? -1;
          newHasPlayers[playerIndex] = true;

          // Set dealer
          if (participant['is_dealer'] == 1) {
            dealerPosition = playerIndex;
          }
        }

        // Update player data
        playerNames.setAll(0, newPlayerNames);
        playerIds.setAll(0, newPlayerIds);
        hasPlayers.setAll(0, newHasPlayers);

        // Update scores from the most recent game data
        final lastGame = games.last;
        if (lastGame['points'] != null) {
          final List<dynamic> pointsList = jsonDecode(lastGame['points']);
          for (int i = 0; i < pointsList.length && i < scores.length; i++) {
            scores[i] = pointsList[i] as int;
          }
        }

        // Set game state
        handsPlayedInRound = 1; // Default to 1 for resumed games

        // Show confirmation message
        _showSnackbar('Game loaded successfully!', Colors.green);
      });
    } catch (e) {
      _showSnackbar('Error loading game: ${e.toString()}', Colors.red);
    }
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
              result.containsKey('points') &&
              result.containsKey('loserIndices')) {
            final winnerIndex = result['winnerIndex'] as int;
            final points = result['points'] as int;
            final loserIndices = result['loserIndices'] as List<int>;

            // Update winner's score
            scores[winnerIndex] += points;

            // Calculate how much each loser pays
            final pointsPerLoser = (points / loserIndices.length).ceil();

            // Update losers' scores
            for (final loserIndex in loserIndices) {
              scores[loserIndex] -= pointsPerLoser;
            }

            // Record this game in the database
            //_recordGameInDatabase(winnerIndex, points, loserIndices);

            // If current dealer won, they keep the dealership and just increment hand count
            if (winnerIndex == dealerPosition) {
              // Increment hands in current round
              handsPlayedInRound++;

              // Check if we need to change the prevalent wind after all hands in a round
              if (handsPlayedInRound >= 4) {
                handsPlayedInRound = 0;
                currentWindIndex = (currentWindIndex + 1) % winds.length;
                isNewRound = true;

                // Show message for new round
                _showSnackbar(
                    "New round: ${winds[currentWindIndex]} wind", Colors.amber);
              } else {
                // Dealer won - show a message
                _showSnackbar("${playerNames[dealerPosition]} keeps dealership",
                    Colors.green);
              }
            } else {
              // Non-dealer won, rotate dealership
              _rotateDealership();
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

  // Add this helper method to convert string to SeatPosition enum
  SeatPosition _seatPositionFromString(String value) {
    return SeatPosition.values.firstWhere(
      (position) => position.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SeatPosition.east, // Default to east if not found
    );
  }

  // Add this helper method to record the game
  Future<void> _recordGameInDatabase(
      int winnerIndex, int points, List<int> loserIndices) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // Create a new match record if one doesn't exist yet
      if (_currentMatchId == -1) {
        final now = DateTime.now();
        _currentMatchId = await dbHelper.insertMatch(startTime: now);

        // Add all players as match participants
        for (int i = 0; i < playerIds.length; i++) {
          if (playerIds[i] != -1) {
            await dbHelper.insertParticipant(
              userId: playerIds[i],
              matchId: _currentMatchId,
              seatPosition: _seatPositionFromString(getSeatWind(i)),
              isDealer: i == dealerPosition,
            );
          }
        }
      }

      // Create winners array
      final List<bool> winners = List.filled(4, false);
      winners[winnerIndex] = true;

      // Insert game record
      await dbHelper.insertGame(
        matchId: _currentMatchId,
        points: scores,
        isWinner: winners,
        winningTile: [_lastWinningTiles], // Store the tiles if available
      );
    } catch (e) {
      _showSnackbar('Failed to record game: $e', Colors.red);
    }
  }
}
