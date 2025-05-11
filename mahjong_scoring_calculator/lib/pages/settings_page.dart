import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();

  // Controller for text inputs
  final _maxFanController = TextEditingController();
  final _fanToPointRatioController = TextEditingController();

  // Local state
  late int _maxFan;
  late bool _hideDebugButtons;
  late double _fanToPointRatio;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from service
    _maxFan = _settingsService.maxFan;
    _hideDebugButtons = _settingsService.hideDebugButtons;
    _fanToPointRatio = _settingsService.fanToPointRatio;

    // Set text controller values
    _maxFanController.text = _maxFan.toString();
    _fanToPointRatioController.text = _fanToPointRatio.toString();
  }

  @override
  void dispose() {
    _maxFanController.dispose();
    _fanToPointRatioController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    // Parse and validate values
    int maxFan =
        int.tryParse(_maxFanController.text) ?? SettingsService.defaultMaxFan;
    double fanToPointRatio = double.tryParse(_fanToPointRatioController.text) ??
        SettingsService.defaultFanToPointRatio;

    // Apply minimum values
    if (maxFan <= 0) maxFan = 1;
    if (fanToPointRatio <= 0) fanToPointRatio = 0.1;

    // Update controllers with sanitized values
    _maxFanController.text = maxFan.toString();
    _fanToPointRatioController.text = fanToPointRatio.toString();

    // Save all settings at once
    await _settingsService.saveAllSettings(
      maxFan: maxFan,
      hideDebugButtons: _hideDebugButtons,
      fanToPointRatio: fanToPointRatio,
    );

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );

      // Return to previous screen
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Max Fan Setting
              const Text(
                'Max Fan Setting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxFanController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter maximum fan (e.g., 13)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Hide Debug Buttons Setting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hide Debug Buttons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _hideDebugButtons,
                    onChanged: (value) {
                      setState(() {
                        _hideDebugButtons = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fan to Point Ratio Setting
              const Text(
                'Fan to Point Ratio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fanToPointRatioController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter ratio (e.g., 1.0)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
