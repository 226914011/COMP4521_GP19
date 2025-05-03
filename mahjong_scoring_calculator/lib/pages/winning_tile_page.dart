import 'package:flutter/material.dart';
import 'package:mahjong_scoring_calculator/widgets/custom_bottom_bar.dart';

class WinningTilePage extends StatefulWidget {
  const WinningTilePage({super.key});

  @override
  State<WinningTilePage> createState() => _WinningTilePageState();
}

class _WinningTilePageState extends State<WinningTilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}