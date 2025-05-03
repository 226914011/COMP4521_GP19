import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/mahjong_tile_container.dart';
import '../widgets/selected_tile_container.dart';
import '../widgets/custom_button.dart';
import 'tile_camera_page.dart';

class WinningTilePage extends StatefulWidget {
  const WinningTilePage({super.key});

  @override
  State<WinningTilePage> createState() => _WinningTilePageState();
}

class _WinningTilePageState extends State<WinningTilePage> {
  final List<String> _selectedTiles = [];

  void _addTile(String tile) {
    if (_selectedTiles.length < 18) {
      setState(() => _selectedTiles.add(tile));
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
              selectedTiles: _selectedTiles,
              onRemove: _removeTile,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: mahjongContainerWidth,
                    child: MahjongTileContainer(
                      width: mahjongContainerWidth,
                      onTileSelected: _addTile,
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
                              onPressed: () async {
                                final imagePath = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TileCameraPage(),
                                  ),
                                );

                                if (imagePath != null) {
                                  // Handle the captured image
                                  // For now, let's just add a placeholder tile to indicate a photo was taken
                                  _addTile(
                                      'camera'); // You may want to replace this with actual image processing

                                  // Show a small preview of the captured image
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Image.file(
                                            File(imagePath),
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                              'Image captured successfully'),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
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
