import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'pages/main_page.dart';
import 'pages/scanning_page.dart';
import 'pages/winning_tile_page.dart';
import 'pages/test_page.dart';
import 'pages/history_page.dart'; // Import the new HistoryPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database; // Trigger database creation
  } catch (e) {
    print('Database initialization failed: $e');
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mahjong Scoring Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/main': (context) => const MainPage(),
          '/winning_tile': (context) => WinningTilePage(
                playerNames: ModalRoute.of(context)!.settings.arguments
                        as List<String>? ??
                    ['Player 1', 'Player 2', 'Player 3', 'Player 4'],
              ),
          '/scanning': (context) => const ScanningPage(),
          '/test': (context) => const TestPage(),
          '/history': (context) => const HistoryPage(), // Add this line
        });
  }
}
