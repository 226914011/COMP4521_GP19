import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final VoidCallback onHelpPressed;
  final VoidCallback onSettingsPressed;

  const CustomBottomBar({
    super.key,
    required this.onHelpPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: MediaQuery.of(context).size.height * 0.1333,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionButton(
              icon: Icons.help_outline,
              label: 'Help',
              onPressed: onHelpPressed,
            ),
            const SizedBox(width: 20),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Settings',
              onPressed: onSettingsPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}