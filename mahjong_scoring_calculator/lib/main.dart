import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/scanning_page.dart';
import 'pages/winning_tile_page.dart';
import 'pages/test_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        '/winning_tile': (context) => const WinningTilePage(),
        '/scanning': (context) => const ScanningPage(),
        '/test': (context) => const TestPage(),
      }
    );
  }
}