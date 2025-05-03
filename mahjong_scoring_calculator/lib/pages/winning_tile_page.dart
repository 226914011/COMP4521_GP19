import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/mahjong_tile_container.dart';
import '../widgets/selected_tile_container.dart';
import '../widgets/custom_button.dart';

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
                                onPressed: () {},
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
        )
      ),
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