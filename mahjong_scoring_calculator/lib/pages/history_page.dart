import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../database/model/user.dart';
import '../widgets/custom_bottom_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<User> _users = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _matchHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper.instance;

      // Load users
      final users = await dbHelper.getAllUsers();

      // Load match history
      final matches = await dbHelper.getMatchHistory(limit: 20);

      setState(() {
        _users.clear();
        _users.addAll(users);
        _matchHistory = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Error loading history: $e', Colors.red);
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showMatchDetails(int matchId) async {
    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper.instance;
      final details = await dbHelper.getMatchDetails(matchId);

      setState(() => _isLoading = false);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Match #$matchId Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(details['matchInfo']['start_time']))}'),
                  const SizedBox(height: 16),
                  const Text('Final Scores:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(details['finalScores'] as Map<String, dynamic>)
                      .entries
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text('${entry.key}: ${entry.value}'),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text('Players:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(details['participants'] as List).map((participant) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                          '${participant['username']} (${participant['seat_position']}${participant['is_dealer'] == 1 ? ', Dealer' : ''})'),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Error loading match details: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Match History'),
            Tab(text: 'Player Statistics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMatchHistoryTab(),
                _buildPlayerStatsTab(),
              ],
            ),
      bottomNavigationBar: const CustomBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMatchHistoryTab() {
    if (_matchHistory.isEmpty) {
      return const Center(child: Text('No matches found'));
    }

    return ListView.builder(
      itemCount: _matchHistory.length,
      itemBuilder: (context, index) {
        final match = _matchHistory[index];
        final startTime = DateTime.parse(match['start_time']);
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(startTime);

        return ListTile(
          title: Text('Match #${match['match_id']}'),
          subtitle: Text(
              '$formattedDate • ${match['player_count']} players • Dealer: ${match['dealer_name'] ?? 'Unknown'}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showMatchDetails(match['match_id']),
        );
      },
    );
  }

  Widget _buildPlayerStatsTab() {
    if (_users.isEmpty) {
      return const Center(child: Text('No players found'));
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildPlayerStatCard(user);
      },
    );
  }

  Widget _buildPlayerStatCard(User user) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getPlayerStatistics(user.userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.username ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Failed to load statistics'),
                ],
              ),
            ),
          );
        }

        final stats = snapshot.data!;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatRow('Games Played', '${stats['gamesPlayed']}'),
                _buildStatRow('Wins', '${stats['wins']}'),
                _buildStatRow(
                    'Win Rate', '${stats['winRate'].toStringAsFixed(1)}%'),
                _buildStatRow('Average Score', '${stats['averageScore']}'),
                _buildStatRow('Highest Score', '${stats['highestScore']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
