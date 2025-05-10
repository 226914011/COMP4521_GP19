import 'package:flutter/material.dart';
import 'dart:io';
import '../services/mahjong_api_service.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/mahjong_tile_container.dart';
import '../widgets/selected_tile_container.dart';
import '../widgets/custom_button.dart';
import '../yolo/model.dart';
import 'scanning_page.dart';

class WinningTilePage extends StatefulWidget {
  final List<String> playerNames;

  const WinningTilePage({
    super.key,
    required this.playerNames,
  });

  @override
  State<WinningTilePage> createState() => _WinningTilePageState();
}

class _WinningTilePageState extends State<WinningTilePage> {
  final int _maxTiles = 14;
  final List<String> _selectedTiles = [];
  bool _isLoading = false;

  // Add new state variables for winner and loser selection
  int _selectedWinnerIndex = 0; // Default to first player
  late List<bool> _selectedLosers; // Will be initialized in initState
  int _calculatedPoints = 0; // Points will be calculated based on the hand

  final MahjongApiService _apiService = MahjongApiService();

  @override
  void initState() {
    super.initState();
    // Initialize losers list with the right length based on player count
    _selectedLosers = List.generate(
        widget.playerNames.length, (index) => index != _selectedWinnerIndex);
  }

  // Helper to update losers when winner changes
  void _updateLosers(int winnerIndex) {
    setState(() {
      _selectedLosers = List.generate(
          widget.playerNames.length, (index) => index != winnerIndex);
    });
  }

  void _addTile(String tile) {
    if (_selectedTiles.length < _maxTiles) {
      setState(() => _selectedTiles.add(tile));
    }
  }

  void _addTilesByCamera(List<String> tiles) {
    _clearTiles();
    for (var tile in tiles) {
      if (_selectedTiles.length < _maxTiles) {
        _addTile(tile);
      }
    }
  }

  void _removeTile(int index) {
    setState(() => _selectedTiles.removeAt(index));
  }

  void _clearTiles() {
    setState(() => _selectedTiles.clear());
  }

  // Update the confirmation method to use player indices
  void _confirmSelection() async {
    // Check if we have enough tiles
    if (_selectedTiles.length < _maxTiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select $_maxTiles tiles for a complete hand')),
      );
      return;
    }

    // Check if at least one loser is selected
    if (!_selectedLosers.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one losing player')),
      );
      return;
    }

    final tiles = createMahjongTiles(_selectedTiles);
    try {
      final response = await _apiService.calculateFaanFromTiles(tiles);
      print(response);
      final faan = response['faan'] as int;
      //print('Faan: $faan');
      _calculatedPoints = faan;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return;
    }

    // Create list of loser indices
    List<int> loserIndices = [];
    for (int i = 0; i < _selectedLosers.length; i++) {
      if (_selectedLosers[i]) {
        loserIndices.add(i);
      }
    }

    // Return data to previous screen
    Navigator.pop(context, {
      'winnerIndex': _selectedWinnerIndex,
      'loserIndices': loserIndices,
      'points': _calculatedPoints,
      'tiles': List<String>.from(_selectedTiles),
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final mahjongContainerWidth = deviceSize.width * 0.55;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Selected tiles display
              SelectedTileContainer(
                tileCount: _maxTiles,
                selectedTiles: _selectedTiles,
                onRemove: (index) {
                  if (!_isLoading) {
                    _removeTile(index);
                  }
                },
              ),

              // Winner and loser selection UI
              _buildPlayerSelectionUI(),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: mahjongContainerWidth,
                      child: MahjongTileContainer(
                        width: mahjongContainerWidth,
                        onTileSelected: (tile) {
                          if (!_isLoading) {
                            _addTile(tile);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: deviceSize.width * 0.15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restart_alt),
                                onPressed: _clearTiles,
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        final imagePath =
                                            await Navigator.push<String>(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ScanningPage()),
                                        );

                                        if (imagePath != null) {
                                          setState(() => _isLoading = true);
                                          try {
                                            final apiResult =
                                                await extractTilesFromImage(
                                                    File(imagePath));
                                            final outputs = apiResult['outputs']
                                                as List<dynamic>;
                                            final Map<String, dynamic>
                                                firstOutput = outputs[0]
                                                    as Map<String, dynamic>;
                                            final Map<String, dynamic>
                                                predictionsData =
                                                firstOutput['predictions']
                                                    as Map<String, dynamic>;
                                            final List<dynamic>
                                                predictionsList =
                                                predictionsData['predictions']
                                                    as List<dynamic>;
                                            final processedTiles =
                                                processPredictions(
                                                    predictionsList);
                                            _addTilesByCamera(processedTiles);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Image.file(File(imagePath),
                                                        height: 40, width: 40),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                        'Added ${processedTiles.length} tiles from scan'),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error: ${e.toString()}')),
                                            );
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                          _buildActionButton('Extra', context),
                          _buildActionButton('Manual', context),
                          _buildActionButton('Confirm', context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  // Update the player selection UI to use player names
  Widget _buildPlayerSelectionUI() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      height: MediaQuery.of(context).size.height * 0.12,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          const Text('Winner:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          // Dropdown with player names instead of wind directions
          DropdownButton<int>(
            value: _selectedWinnerIndex,
            items: List.generate(
              widget.playerNames.length,
              (index) => DropdownMenuItem(
                  value: index, child: Text(widget.playerNames[index])),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedWinnerIndex = value;
                  _updateLosers(value); // Update losers when winner changes
                });
              }
            },
          ),
          const Spacer(),
          const Text('Losers:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          // Checkboxes with player initials or names
          for (int i = 0; i < widget.playerNames.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedLosers[i],
                    onChanged: _selectedWinnerIndex == i
                        ? null // Disable if this is the winner
                        : (value) {
                            setState(() {
                              _selectedLosers[i] = value!;
                            });
                          },
                  ),
                  Text(widget.playerNames[i].isNotEmpty
                      ? widget.playerNames[i].substring(0, 1) // First initial
                      : '$i'), // Fallback to index if name is empty
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, BuildContext context) {
    VoidCallback? callback;

    if (text == 'Confirm') {
      callback = _isLoading ? null : _confirmSelection;
    } else if (text == 'Extra') {
      callback = () {
        // Implement Extra functionality
      };
    } else if (text == 'Manual') {
      callback = () {
        // Implement Manual functionality
      };
    }

    return CustomButton(
      text: text,
      onPressed: callback,
      width: MediaQuery.of(context).size.width * 0.12,
      height: MediaQuery.of(context).size.height * 0.08,
      fontSize: 12,
    );
  }
}
