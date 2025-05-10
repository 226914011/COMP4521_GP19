import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> extractTilesFromImage(File imagePath) async {
  try {
    final bytes = imagePath.readAsBytesSync();

    final imageList = bytes.buffer.asUint8List();
    String base64Image = "";
    if (imageList.isNotEmpty) {
      base64Image = base64Encode(imageList);
    } else {
      if (kDebugMode) {
        print("no image list found");
      }
      return {"error": "No image data found"};
    }

    const apiKey = "3xxccwZJ583VW1srMge4";
    final url =
        "https://serverless.roboflow.com/infer/workflows/mobile-project/detect-count-and-visualize";

    // Based on the Node.js example
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        "api_key": apiKey,
        "inputs": {
          "image": {
            "type": "base64",
            "value": base64Image,
          }
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print('Success: ${response.body}');
      }
      return jsonDecode(response.body);
    } else {
      if (kDebugMode) {
        print(
            'Error: Status Code ${response.statusCode}, Response: ${response.body}');
      }
      return {
        "error": "API Error: ${response.statusCode}",
        "message": response.body
      };
    }
  } catch (e) {
    if (kDebugMode) {
      print('Exception: ${e.toString()}');
    }
    return {"error": e.toString()};
  }
}

Future<Map<String, dynamic>> testAPI() async {
  try {
    // Directly load asset without temporary file
    final ByteData data = await rootBundle.load('assets/test/test_yolo_1.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final base64Image = base64Encode(bytes);

    const apiKey = "3xxccwZJ583VW1srMge4";
    final url =
        "https://serverless.roboflow.com/infer/workflows/mobile-project/detect-count-and-visualize";

    // Use the same approach as the Node.js example
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "api_key": apiKey,
        "inputs": {
          "image": {
            "type": "base64",
            "value": base64Image,
          }
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "error": "API Error: ${response.statusCode}",
        "message": response.body
      };
    }
  } catch (e) {
    return {"error": e.toString()};
  }
}

// Add a new method to support URL-based inference (like the second Node.js example)
Future<Map<String, dynamic>> testAPIWithImageURL(String imageUrl) async {
  try {
    const apiKey = "3xxccwZJ583VW1srMge4";

    // Create URL with query parameters for both API key and image URL
    final url = Uri.parse("https://serverless.roboflow.com/master-oez61/7")
        .replace(queryParameters: {
      'api_key': apiKey,
      'image': imageUrl,
    });

    // No body needed in this case, just a GET request
    final response = await http.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "error": "API Error: ${response.statusCode}",
        "message": response.body
      };
    }
  } catch (e) {
    return {"error": e.toString()};
  }
}

List<String> processPredictions(List<dynamic> predictions) {
  // Filter invalid classes
  final valid = predictions
      .where((p) => !['0m', '0p', '0s', '0b'].contains(p['class']))
      .toList();

  // Sort by confidence
  valid.sort((a, b) => b['confidence'].compareTo(a['confidence']));

  // Take top 14
  final top = valid.take(14).toList();

  // Sort by x coordinate in ascending order (left to right)
  top.sort((a, b) => a['x'].compareTo(b['x']));

  // Map labels
  return top.map((p) {
    final label = p['class'];
    final type = label.substring(label.length - 1);
    final number = int.parse(label.substring(0, label.length - 1));

    switch (type) {
      case 'm':
        return 'man$number';
      case 'p':
        return 'pin$number';
      case 's':
        return 'bamboo$number';
      case 'z':
        if (number <= 4)
          return 'wind-${['east', 'south', 'west', 'north'][number - 1]}';
        return 'dragon-${['haku', 'green', 'chun'][number - 5]}';
      default:
        return 'unknown';
    }
  }).toList();
}
