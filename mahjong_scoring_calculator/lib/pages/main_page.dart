import 'package:flutter/material.dart';
import 'dart:convert'; // Import for jsonEncode

// Import your widgets and the new handler/service
import '../widgets/custom_bottom_bar.dart';
import '../widgets/player_container.dart';
import '../widgets/custom_button.dart';
import 'winning_tile_page.dart'; 
import '../utils/api_test_handler.dart'; 
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // --- Existing Game State ---
  bool gameStarted = false;
  final List<bool> hasPlayers = [false, false, false, false];
  final playerNames = ['', '', '', '']; 
  final scores = [0, 0, 0, 0]; 

  // --- API Testing State & Handler ---
  final ApiTestHandler _apiTestHandler = ApiTestHandler(); // Instance of the handler

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
      setState(() { _meldApiResult = result; });
      _showSnackbar('Meld API Success!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = "Meld Test Failed: ${e.toString()}";
      setState(() { _meldApiError = errorMessage; });
      _showSnackbar(errorMessage, Colors.red);
    } finally {
      if (!mounted) return;
      setState(() { _isMeldLoading = false; }); // Ensure loading stops
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
      setState(() { _rawTileApiResult = result; });
      _showSnackbar('Raw Tile API Success!', Colors.blue);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = "Raw Tile Test Failed: ${e.toString()}";
      setState(() { _rawTileApiError = errorMessage; });
      _showSnackbar(errorMessage, Colors.orange);
    } finally {
      if (!mounted) return;
      setState(() { _isRawTileLoading = false; }); // Ensure loading stops
    }
  }

  // --- Snackbar Helper Method ---
  void _showSnackbar(String message, Color backgroundColor) {
     if (mounted) { // Check if the widget is still in the tree
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

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size; // Keep if CustomButton uses it

    return Scaffold(
      body: SafeArea(child:
        Column(
          children: [
            // Row 0
            Expanded(
              child: Row(
                children: [
                  // (0,0) - API Test Buttons & Results
                  _buildGridCell(
                     SingleChildScrollView( // Use ScrollView for long results
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             // Meld Test Button & Result Display
                             ElevatedButton(
                               onPressed: _isMeldLoading ? null : _runMeldTest,
                               child: _isMeldLoading
                                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                   : const Text('Test Melds API'),
                             ),
                             // Conditional display for Meld results/errors
                             if (_meldApiResult != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(
                                   'Meld OK: ${jsonEncode(_meldApiResult)}', // Display JSON result
                                   style: const TextStyle(fontSize: 10, color: Colors.green),
                                   textAlign: TextAlign.center,
                                 ),
                               ),
                             if (_meldApiError != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(
                                   _meldApiError!, // Display error message
                                   style: const TextStyle(fontSize: 10, color: Colors.red),
                                   textAlign: TextAlign.center,
                                  ),
                               ),

                             const SizedBox(height: 15), // Spacer

                             // Raw Tile Test Button & Result Display
                              ElevatedButton(
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                               onPressed: _isRawTileLoading ? null : _runRawTileTest,
                               child: _isRawTileLoading
                                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                   : const Text('Test Raw Tiles API'),
                             ),
                             // Conditional display for Raw Tile results/errors
                              if (_rawTileApiResult != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(
                                   'Raw OK: ${jsonEncode(_rawTileApiResult)}', // Display JSON result
                                   style: const TextStyle(fontSize: 10, color: Colors.blue),
                                   textAlign: TextAlign.center,
                                  ),
                               ),
                             if (_rawTileApiError != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(
                                   _rawTileApiError!, // Display error message
                                   style: const TextStyle(fontSize: 10, color: Colors.orange),
                                   textAlign: TextAlign.center,
                                  ),
                               ),
                           ],
                         ),
                       ),
                     )
                  ),

                  // (0,1) Player 1 Container (Your existing code)
                  _buildGridCell(PlayerContainer(
                    hasPlayer: hasPlayers[0],
                    gameStarted: gameStarted,
                    onAdd: () => setState(() => hasPlayers[0] = true),
                    onReset: () => setState(() => hasPlayers[0] = false),
                  )),

                  // (0,2) Game Controls (Your existing code)
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

            // Row 1 (Your existing code)
            Expanded(
              child: Row(
                children: [
                  _buildGridCell(PlayerContainer( gameStarted: gameStarted, hasPlayer: hasPlayers[1], onAdd: () => setState(() => hasPlayers[1] = true), onReset: () => setState(() => hasPlayers[1] = false), )),
                  _buildGridCell( gameStarted ? Container( /* Wind Indicator */ padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration( color: Colors.amber[100], borderRadius: BorderRadius.circular(30), ), child: const Text('Prevalent wind: East', style: TextStyle(fontSize: 16)), ) : CustomButton( text: 'Start Game', width: deviceSize.width * 0.2, height: deviceSize.height * 0.15, fontSize: 18, borderRadius: deviceSize.width * 0.1, onPressed: _checkStartGame, ), ),
                  _buildGridCell(PlayerContainer( gameStarted: gameStarted, hasPlayer: hasPlayers[2], onAdd: () => setState(() => hasPlayers[2] = true), onReset: () => setState(() => hasPlayers[2] = false), )),
                ],
              ),
            ),

            // Row 2 (Your existing code)
            Expanded(
              child: Row(
                children: [
                  _buildGridCell(const SizedBox.shrink()),
                  _buildGridCell(PlayerContainer( gameStarted: gameStarted, hasPlayer: hasPlayers[3], onAdd: () => setState(() => hasPlayers[3] = true), onReset: () => setState(() => hasPlayers[3] = false), )),
                  _buildGridCell( gameStarted ? Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ CustomButton(text: 'Draw', onPressed: _draw), CustomButton(text: 'Win', onPressed: _win), ], ) : const SizedBox.shrink(), ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Your existing bottom navigation bar
      bottomNavigationBar: CustomBottomBar(
          onDebugPressed: () {
             print("Debug button pressed, navigating..."); // Or remove if not needed
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const WinningTilePage()),
             );
          }
      ),
    );
  }

  static void _saveAndLoadGame() {}
  static void _loadGameHistory() {}
  static void _draw() {}
  static void _win() {}
}