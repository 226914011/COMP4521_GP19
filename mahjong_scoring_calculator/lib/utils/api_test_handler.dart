// For logging JSON if needed

// Import the service and data models
import '../services/mahjong_api_service.dart';

class ApiTestHandler {
  // Instantiate the service
  final MahjongApiService _apiService = MahjongApiService();

  // --- Dummy Data Definitions ---

  List<MahjongMeld> _createDummyMelds() {
    // Example: Common Hand (Ping Wu) - Modify as needed for your tests
    return [
      MahjongMeld(tiles: [ MahjongTile(suit: 'dot', value: 1), MahjongTile(suit: 'dot', value: 2), MahjongTile(suit: 'dot', value: 3), ]),
      MahjongMeld(tiles: [ MahjongTile(suit: 'dot', value: 4), MahjongTile(suit: 'dot', value: 5), MahjongTile(suit: 'dot', value: 6), ]),
      MahjongMeld(tiles: [ MahjongTile(suit: 'bamboo', value: 7), MahjongTile(suit: 'bamboo', value: 8), MahjongTile(suit: 'bamboo', value: 9), ]),
      MahjongMeld(tiles: [ MahjongTile(suit: 'character', value: 1), MahjongTile(suit: 'character', value: 2), MahjongTile(suit: 'character', value: 3), ]),
      MahjongMeld(tiles: [ MahjongTile(suit: 'character', value: 5), MahjongTile(suit: 'character', value: 5), ]), // Eyes
    ];
  }

  List<MahjongTile> _createDummyRawTiles() {
    // Example: Mixed Suit hand - Modify as needed for your tests
    return [
      MahjongTile(suit: 'dot', value: 1), MahjongTile(suit: 'dot', value: 1), MahjongTile(suit: 'dot', value: 2),
      MahjongTile(suit: 'dot', value: 2), MahjongTile(suit: 'dot', value: 1), MahjongTile(suit: 'dot', value: 2),
      MahjongTile(suit: 'bamboo', value: 2), MahjongTile(suit: 'bamboo', value: 2), MahjongTile(suit: 'bamboo', value: 2),
      MahjongTile(suit: 'character', value: 8), MahjongTile(suit: 'character', value: 8), MahjongTile(suit: 'character', value: 8),
      MahjongTile(suit: 'character', value: 9), MahjongTile(suit: 'character', value: 9),
    ];
  }

  // --- Public Methods to Execute Tests ---

  /// Calls the backend API with pre-defined melds.
  /// Returns the result Map on success, throws an Exception on failure.
  Future<Map<String, dynamic>> executeMeldTest() async {
    final List<MahjongMeld> dummyMelds = _createDummyMelds();
    // Add config if needed for this test
    final Map<String, dynamic> config = {"selfPick": false};
    print("Handler: Executing Meld Test...");
    // Let the service handle the actual call and error throwing
    return await _apiService.calculateFaan(dummyMelds, config: config);
  }

  /// Calls the backend API with raw tiles.
  /// Returns the result Map on success, throws an Exception on failure.
  Future<Map<String, dynamic>> executeRawTileTest() async {
    final List<MahjongTile> dummyTiles = _createDummyRawTiles();
    // Add config if needed for this test
    final Map<String, dynamic> config = {"selfPick": true};
    print("Handler: Executing Raw Tile Test...");
    // Let the service handle the actual call and error throwing
    return await _apiService.calculateFaanFromTiles(dummyTiles, config: config);
  }
}
