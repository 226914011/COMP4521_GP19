import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Keys for SharedPreferences
  static const String _maxFanKey = 'maxFan';
  static const String _hideDebugButtonsKey = 'hideDebugButtons';
  static const String _fanToPointRatioKey = 'fanToPointRatio';

  // Default values
  static const int defaultMaxFan = 13;
  static const bool defaultHideDebugButtons =
      true; // Start with debug buttons hidden
  static const double defaultFanToPointRatio = 1.0;

  // Cache for current settings values
  int _maxFan = defaultMaxFan;
  bool _hideDebugButtons = defaultHideDebugButtons;
  double _fanToPointRatio = defaultFanToPointRatio;

  // Stream controllers for settings changes
  final _maxFanController = StreamController<int>.broadcast();
  final _hideDebugButtonsController = StreamController<bool>.broadcast();
  final _fanToPointRatioController = StreamController<double>.broadcast();

  // Stream getters
  Stream<int> get maxFanStream => _maxFanController.stream;
  Stream<bool> get hideDebugButtonsStream => _hideDebugButtonsController.stream;
  Stream<double> get fanToPointRatioStream => _fanToPointRatioController.stream;

  // Initialize settings from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load all settings with proper defaults
    _maxFan = prefs.getInt(_maxFanKey) ?? defaultMaxFan;
    _hideDebugButtons =
        prefs.getBool(_hideDebugButtonsKey) ?? defaultHideDebugButtons;
    _fanToPointRatio =
        prefs.getDouble(_fanToPointRatioKey) ?? defaultFanToPointRatio;

    // Emit initial values
    _maxFanController.add(_maxFan);
    _hideDebugButtonsController.add(_hideDebugButtons);
    _fanToPointRatioController.add(_fanToPointRatio);
  }

  // Dispose method to clean up resources
  void dispose() {
    _maxFanController.close();
    _hideDebugButtonsController.close();
    _fanToPointRatioController.close();
  }

  // Getters for current values
  int get maxFan => _maxFan;
  bool get hideDebugButtons => _hideDebugButtons;
  double get fanToPointRatio => _fanToPointRatio;

  // Setters that update preferences and notify listeners
  Future<void> setMaxFan(int value) async {
    if (_maxFan == value) return;
    _maxFan = value;
    _maxFanController.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxFanKey, value);
  }

  Future<void> setHideDebugButtons(bool value) async {
    if (_hideDebugButtons == value) return;
    _hideDebugButtons = value;
    _hideDebugButtonsController.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideDebugButtonsKey, value);
  }

  Future<void> setFanToPointRatio(double value) async {
    if (_fanToPointRatio == value) return;
    _fanToPointRatio = value;
    _fanToPointRatioController.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fanToPointRatioKey, value);
  }

  // Save all settings at once (useful for settings page)
  Future<void> saveAllSettings({
    required int maxFan,
    required bool hideDebugButtons,
    required double fanToPointRatio,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Update all values at once
    await Future.wait([
      prefs.setInt(_maxFanKey, maxFan),
      prefs.setBool(_hideDebugButtonsKey, hideDebugButtons),
      prefs.setDouble(_fanToPointRatioKey, fanToPointRatio),
    ]);

    // Update cache and notify listeners if values changed
    if (_maxFan != maxFan) {
      _maxFan = maxFan;
      _maxFanController.add(maxFan);
    }

    if (_hideDebugButtons != hideDebugButtons) {
      _hideDebugButtons = hideDebugButtons;
      _hideDebugButtonsController.add(hideDebugButtons);
    }

    if (_fanToPointRatio != fanToPointRatio) {
      _fanToPointRatio = fanToPointRatio;
      _fanToPointRatioController.add(fanToPointRatio);
    }
  }
}
