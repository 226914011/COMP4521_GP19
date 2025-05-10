import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../yolo/model.dart';
import 'scanning_page.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _response = 'Press button to test API';
  bool _isLoading = false;

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _response = 'Testing...';
    });

    try {
      final result = await testAPI();
      setState(() => _response = _formatJson(jsonEncode(result)));
    } catch (e) {
      setState(() => _response = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runCameraTest() async {
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanningPage()),
    );

    if (imagePath == null) return;

    setState(() {
      _isLoading = true;
      _response = 'Testing...';
    });

    try {
      final result = await extractTilesFromImage(File(imagePath));
      final outputs = result['outputs'] as List<dynamic>;
      final Map<String, dynamic> firstOutput = outputs[0] as Map<String, dynamic>;
      final Map<String, dynamic> predictionsData = firstOutput['predictions'] as Map<String, dynamic>;
      final List<dynamic> predictionsList = predictionsData['predictions'] as List<dynamic>;
      setState(() => _response = _formatJson(jsonEncode(predictionsList)));
    } catch (e) {
      setState(() => _response = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatJson(String jsonString) {
    try {
      final parsed = json.decode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return jsonString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _runTest,
                  child: const Text('Run API Test'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _runCameraTest,
                  child: const Text('Test API with Camera'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _response,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: _response.startsWith('Error:')
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
