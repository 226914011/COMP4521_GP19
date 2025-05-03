import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // Empty container for main content
      bottomNavigationBar: const CustomBottomBar(
        onHelpPressed: _handleHelp,
        onSettingsPressed: _handleSettings,
      ),
    );
  }

  static void _handleHelp() {
    // Add help logic
  }

  static void _handleSettings() {
    // Add settings logic
  }
}