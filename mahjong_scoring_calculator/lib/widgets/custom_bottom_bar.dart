import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBottomBar extends StatefulWidget {
  final VoidCallback? onDebugPressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onSettingsPressed;

  const CustomBottomBar({
    super.key,
    this.onDebugPressed,
    this.onHelpPressed,
    this.onSettingsPressed,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('d/M/yyyy HH:mm:ss').format(now);
    });
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
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final barHeight = deviceHeight * 0.1333;
    final buttonWidth = deviceWidth * 0.125;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Stack(
        children: [
          // Debug Button (left)
          if (widget.onDebugPressed != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildButton(
                width: buttonWidth,
                height: barHeight,
                icon: Icons.bug_report,
                label: 'Debug',
                onPressed: widget.onDebugPressed,
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
                  onPressed: widget.onHelpPressed,
                ),
                _buildButton(
                  width: buttonWidth,
                  height: barHeight,
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: widget.onSettingsPressed,
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