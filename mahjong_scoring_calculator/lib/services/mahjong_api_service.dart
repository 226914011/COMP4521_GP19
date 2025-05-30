import 'dart:convert';
import 'package:http/http.dart' as http;

// Data Models (keep these consistent with your backend)
class MahjongTile {
  final String suit;
  final int value;
  MahjongTile({required this.suit, required this.value});
  Map<String, dynamic> toJson() => {'suit': suit, 'value': value};
}

List<MahjongTile> createMahjongTiles(List<String> input) {
  return input.map(_parseTile).toList();
}

MahjongTile _parseTile(String str) {
  if (str.contains('-')) {
    final parts = str.split('-');
    final firstPart = parts[0];
    final secondPart = parts[1];
    
    if (firstPart == 'wind') {
      const windValues = {
        'east': 1,
        'south': 2,
        'west': 3,
        'north': 4,
      };
      return MahjongTile(suit: 'honor', value: windValues[secondPart]!);
    } else if (firstPart == 'dragon') {
      const dragonValues = {
        'chun': 5,
        'green': 6,
        'haku': 7,
      };
      return MahjongTile(suit: 'honor', value: dragonValues[secondPart]!);
    }
  } else {
    final match = RegExp(r'^(\D+)(\d+)$').firstMatch(str);
    if (match != null) {
      final suitPart = match.group(1)!;
      final value = int.parse(match.group(2)!);
      
      switch (suitPart) {
        case 'pin':
          return MahjongTile(suit: 'dot', value: value);
        case 'bamboo':
          return MahjongTile(suit: 'bamboo', value: value);
        case 'man':
          return MahjongTile(suit: 'character', value: value);
      }
    }
  }
  throw ArgumentError('Invalid tile format: $str');
}

class MahjongMeld {
  final List<MahjongTile> tiles;
  MahjongMeld({required this.tiles});
  Map<String, dynamic> toJson() => {
    'tiles': tiles.map((tile) => tile.toJson()).toList(),
  };
}

class MahjongApiService {
  // Adjust if your backend runs elsewhere or on a different port
  final String _baseUrl = 'https://api-oxmwcvwira-uc.a.run.app'; //'http://localhost:5001/hk-mahjong-36eb0/us-central1/api'; //hk-mahjong-36eb0

  // Method for pre-defined melds (/calculate endpoint)
  // Future<Map<String, dynamic>> calculateFaan(
  //     List<MahjongMeld> melds, {Map<String, dynamic>? config}) async {
  //   final url = Uri.parse('$_baseUrl/calculate');
  //   final body = jsonEncode({
  //     'melds': melds.map((meld) => meld.toJson()).toList(),
  //     if (config != null) 'config': config,
  //   });

  //   print('Sending to API (/calculate): $body');
  //   try {
  //     final response = await http.post(url,
  //         headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //         body: body);
  //     print('API Status Code (/calculate): ${response.statusCode}');
  //     print('API Response Body (/calculate): ${response.body}');

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       Map<String, dynamic> errorResult = {'error': 'API Error'};
  //       try { errorResult = jsonDecode(response.body); } catch (_) {}
  //       throw Exception(
  //           'Failed /calculate: ${response.statusCode} - ${errorResult['error'] ?? response.body}');
  //     }
  //   } catch (e) {
  //     print('Network error /calculate: $e');
  //     throw Exception('Network error /calculate: $e');
  //   }
  // }

  // Method for raw tiles (/calculate-from-tiles endpoint)
  Future<Map<String, dynamic>> calculateFaanFromTiles(
      List<MahjongTile> tiles, {Map<String, dynamic>? config}) async {
    final url = Uri.parse('$_baseUrl/calculate-from-tiles');
    final body = jsonEncode({
      'tiles': tiles.map((tile) => tile.toJson()).toList(),
      if (config != null) 'config': config,
    });

    print('Sending to API (/calculate-from-tiles): $body');
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: body);
      print('API Status Code (/calculate-from-tiles): ${response.statusCode}');
      print('API Response Body (/calculate-from-tiles): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
         Map<String, dynamic> errorResult = {'error': 'API Error'};
         try { errorResult = jsonDecode(response.body); } catch (_) {}
        throw Exception(
            'Failed /calculate-from-tiles: ${response.statusCode} - ${errorResult['error'] ?? response.body}');
      }
    } catch (e) {
      print('Network error /calculate-from-tiles: $e');
      throw Exception('Network error /calculate-from-tiles: $e');
    }
  }
}