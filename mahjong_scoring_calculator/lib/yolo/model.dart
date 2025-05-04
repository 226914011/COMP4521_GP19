import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<void> testRoboflowAPI(File imagePath) async {
  try {
    final bytes = imagePath.readAsBytesSync();
    
    final imageList = bytes.buffer.asUint8List();
    String base64Image = "";
    if(imageList.isNotEmpty) {
      base64Image = base64Encode(imageList);
    } else {
      if (kDebugMode) {
        print("no image list found");
      }
    }

    final url =
        "https://serverless.roboflow.com/master-oez61/7?api_key=3xxccwZJ583VW1srMge4";
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    final body = {
      "data": base64Image,
    };

    final encodedBody = Uri(queryParameters: body).query;
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print('Success: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        print('Error: Status Code ${response.statusCode}, Response: ${response.body}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Exception: ${e.toString()}');
    }
  }
}

Future<String> testAPI() async {
  try {
    // Directly load asset without temporary file
    final ByteData data = await rootBundle.load('assets/test/test_yolo_1.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final base64Image = base64Encode(bytes);
    
    const url = "https://serverless.roboflow.com/master-oez61/7?api_key=3xxccwZJ583VW1srMge4";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': base64Image},
    );

    return response.body;
  } catch (e) {
    return 'Error: ${e.toString()}';
  }
}