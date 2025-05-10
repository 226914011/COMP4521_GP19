import 'package:flutter/material.dart';

class FaanConfigDialog extends StatefulWidget {
  const FaanConfigDialog({super.key});

  @override
  State<FaanConfigDialog> createState() => _FaanConfigDialogState();
}

class _FaanConfigDialogState extends State<FaanConfigDialog> {
  final Map<String, dynamic> _config = {};
  String? _roundWind;
  String? _seatWind;
  final Map<String, bool> _extraTiles = {
    'spring': false,
    'summer': false,
    'autumn': false,
    'winter': false,
    'plum': false,
    'lily': false,
    'chrysanthemum': false,
    'bamboo': false,
  };

  void _updateConfig(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _config.remove(key);
      } else {
        _config[key] = value;
      }
    });
  }

  void _handleExtraTiles(String tile, bool? value) {
    setState(() {
      _extraTiles[tile] = value ?? false;
    });
    
    // Remove empty extraTiles
    final nonEmpty = _extraTiles.entries.where((e) => e.value).toList();
    if (nonEmpty.isEmpty) {
      _config.remove('extraTiles');
    } else {
      _config['extraTiles'] = {
        for (var entry in nonEmpty) entry.key: entry.value
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Additional Configurations'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCheckbox('Self Pick', 'selfPick'),
            _buildCheckbox('Fully Concealed Hand', 'fullyConcealedHand'),
            _buildCheckbox('Robbing Kong', 'robbingKong'),
            _buildCheckbox('Win by Last Catch', 'winByLastCatch'),
            _buildCheckbox('Win by Kong', 'winByKong'),
            _buildCheckbox('Win by Double Kong', 'winByDoubleKong'),
            _buildCheckbox('Heavenly Hand', 'heavenlyHand'),
            _buildCheckbox('Earthly Hand', 'earthlyHand'),
            _buildCheckbox('Eight Immortals', 'eightImmortalsCrossingTheSea'),
            _buildCheckbox('Flowers Hand', 'flowersHand'),
            _buildCheckbox('Bonus for Zero Extra', 'enableBonusFaanDueToZeroExtraTile'),
            
            const SizedBox(height: 16),
            _buildWindDropdown(
              label: 'Round Wind',
              value: _roundWind,
              onChanged: (v) => _updateConfig('roundWind', v),
            ),
            _buildWindDropdown(
              label: 'Seat Wind',
              value: _seatWind,
              onChanged: (v) => _updateConfig('seatWind', v),
            ),
            
            ExpansionTile(
              title: const Text('Extra Tiles'),
              children: [
                ..._extraTiles.keys.map((tile) => CheckboxListTile(
                  title: Text(tile[0].toUpperCase() + tile.substring(1)),
                  value: _extraTiles[tile],
                  onChanged: (v) => _handleExtraTiles(tile, v),
                )).toList(),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => Navigator.pop(context, _config),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, String configKey) {
    return CheckboxListTile(
      title: Text(label),
      value: _config[configKey] ?? false,
      onChanged: (value) => _updateConfig(configKey, value ?? false),
    );
  }

  Widget _buildWindDropdown({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: const [
          DropdownMenuItem(value: 'east', child: Text('East')),
          DropdownMenuItem(value: 'south', child: Text('South')),
          DropdownMenuItem(value: 'west', child: Text('West')),
          DropdownMenuItem(value: 'north', child: Text('North')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}