import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/api_models.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    // Android Emulator uses 10.0.2.2 to access the host machine
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000'; // iOS / Desktop
  }

  Future<MemoryResponse> recordMemory(String text, String? tone) async {
    // 2. Use the dynamic baseUrl
    final url = Uri.parse('$baseUrl/memory/record');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(MemoryCreate(text: text, tone: tone).toJson()),
      );

      if (response.statusCode == 200) {
        return MemoryResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<MemoryResponse> addTextMemory(String text, String? tone) async {
    final url = Uri.parse('$baseUrl/memory/text');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(MemoryCreate(text: text, tone: tone).toJson()),
    );

    if (response.statusCode == 200) {
      return MemoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add text memory: ');
    }
  }

  Future<List<TimelineResponse>> getTimeline({String? date}) async {
    var uri = Uri.parse('$baseUrl/timeline');
    if (date != null) {
      uri = uri.replace(queryParameters: {'date': date});
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => TimelineResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load timeline: ');
    }
  }

  Future<QueryResponse> askAI(String query) async {
    final url = Uri.parse('$baseUrl/ask');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(QueryRequest(query: query).toJson()),
    );

    if (response.statusCode == 200) {
      return QueryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to ask AI: ');
    }
  }
}
