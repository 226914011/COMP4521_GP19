import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import the pages needed for the debug menu
import '../pages/scanning_page.dart';
import '../pages/test_page.dart';
import '../pages/winning_tile_page.dart';
import '../pages/settings_page.dart'; // Add this import
import '../services/settings_service.dart';

class CustomBottomBar extends StatefulWidget {
  final VoidCallback? onHelpPressed;
  final VoidCallback? onSettingsPressed;
  final List<String>?
      playerNames; // Add player names parameter for WinningTilePage
  final bool hideDebugButtons;

  const CustomBottomBar({
    super.key,
    this.onHelpPressed,
    this.onSettingsPressed,
    this.playerNames,
    this.hideDebugButtons = false,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  final _settingsService = SettingsService();
  StreamSubscription? _hideDebugButtonsSubscription;

  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    // Listen for changes to the hideDebugButtons setting
    _hideDebugButtonsSubscription =
        _settingsService.hideDebugButtonsStream.listen(
      (value) {
        if (mounted) {
          setState(() {
            // UI will refresh when setting changes
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _hideDebugButtonsSubscription?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('d/M/yyyy HH:mm:ss').format(now);
    });
  }

  // Moved from MainPage - Debug menu functionality
  void _showDebugMenu() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Debug Menu'),
        children: [
          _buildDebugOption(
              'Winning Tiles Page',
              WinningTilePage(
                  playerNames: widget.playerNames ?? List.filled(4, ''))),
          _buildDebugOption('Scanning Page', const ScanningPage()),
          _buildDebugOption('API Test Page', const TestPage()),
          _buildDebugOption(
              'Settings Page', const SettingsPage()), // Add this line
        ],
      ),
    );
  }

  // Moved from MainPage - Debug option builder
  ListTile _buildDebugOption(String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the dialog
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  void _handleHelp() => widget.onHelpPressed?.call();
  void _handleSettings() {
    if (widget.onSettingsPressed != null) {
      // Use the provided callback if available
      widget.onSettingsPressed!();
    } else {
      // Navigate directly to settings page if no callback is provided
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  Widget _buildButton({
    required double width,
    required double height,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final barHeight = deviceSize.height * 0.1333;
    final buttonWidth = deviceSize.width * 0.125;

    // In your widget's build method, use both the passed prop and the service
    // This allows for backwards compatibility
    final hideDebugButtons =
        widget.hideDebugButtons || _settingsService.hideDebugButtons;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Stack(
        children: [
          // Debug Button (left)
          if (!hideDebugButtons)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildButton(
                width: buttonWidth,
                height: barHeight,
                icon: Icons.bug_report,
                label: 'Debug',
                onPressed: _showDebugMenu,
              ),
            ),
          // Help & Settings Buttons (right)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                _buildButton(
                  width: buttonWidth,
                  height: barHeight,
                  icon: Icons.help,
                  label: 'Help',
                  onPressed: _handleHelp,
                ),
                _buildButton(
                  width: buttonWidth,
                  height: barHeight,
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: _handleSettings,
                ),
              ],
            ),
          ),
          // Centered Time Display
          Center(
            child: Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
