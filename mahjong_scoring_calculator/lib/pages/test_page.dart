import 'dart:convert';

import 'package:flutter/material.dart';
import '../yolo/model.dart';

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
      setState(() => _response = _formatJson(result));
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
            ElevatedButton(
              onPressed: _isLoading ? null : _runTest,
              child: const Text('Run API Test')),
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