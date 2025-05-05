import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/mahjong_tile_container.dart';
import '../widgets/selected_tile_container.dart';
import '../widgets/custom_button.dart';
import '../yolo/model.dart';
import 'scanning_page.dart';

class WinningTilePage extends StatefulWidget {
  const WinningTilePage({super.key});

  @override
  State<WinningTilePage> createState() => _WinningTilePageState();
}

class _WinningTilePageState extends State<WinningTilePage> {
  final int _maxTiles = 14;
  final List<String> _selectedTiles = [];
  bool _isLoading = false;

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
            SelectedTileContainer(
              tileCount: _maxTiles,
              selectedTiles: _selectedTiles,
              onRemove: (index) {
                if (!_isLoading) {
                  _removeTile(index);
                }
              },
            ),
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
                              onPressed: _isLoading ? null : () async {
                                final imagePath = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ScanningPage()),
                                );

                                if (imagePath != null) {
                                  setState(() => _isLoading = true);
                                  try {
                                    final apiResult = await extractTilesFromImage(File(imagePath));
                                    final processedTiles = processPredictions(apiResult['predictions']);
                                    _addTilesByCamera(processedTiles);
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Image.file(File(imagePath), height: 40, width: 40),
                                            const SizedBox(width: 10),
                                            Text('Added ${processedTiles.length} tiles from scan'),
                                          ],
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
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
      )),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildActionButton(String text, BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: () {},
      width: MediaQuery.of(context).size.width * 0.12,
      height: MediaQuery.of(context).size.height * 0.08,
      fontSize: 12,
    );
  }
}
