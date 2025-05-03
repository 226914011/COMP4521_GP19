import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/player_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: PlayerContainer(),
      ),
      bottomNavigationBar: const CustomBottomBar(
        onDebugPressed: _handleDebug,
        onHelpPressed: _handleHelp,
        onSettingsPressed: _handleSettings,
      ),
    );
  }

  static void _handleDebug() {
    // Add debug logic
  }

  static void _handleHelp() {
    // Add help logic
  }

  static void _handleSettings() {
    // Add settings logic
  }
}