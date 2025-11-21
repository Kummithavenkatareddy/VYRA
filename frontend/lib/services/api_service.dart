import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<Map<String, dynamic>> uploadAudioMemory(String filePath) async {
    // TODO: Implement file upload
    // var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/memories/audio'));
    // request.files.add(await http.MultipartFile.fromPath('file', filePath));
    // var response = await request.send();
    
    // Mock response for now
    await Future.delayed(const Duration(seconds: 1));
    return {
      "memory_id": "uuid-123",
      "text": "I met Rahul at the cafe...",
      "timestamp": DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> createTextMemory(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/memories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Mock fallback
      return {"memory_id": "uuid-mock"};
    }
  }

  Future<List<dynamic>> getMemories() async {
    // final response = await http.get(Uri.parse('$baseUrl/memories?user_id=XYZ'));
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body)['memories'];
    // }
    
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "memory_id": "uuid-1",
        "text": "I met Rahul...",
        "timestamp": "2025-02-02T18:30:00Z"
      },
      {
        "memory_id": "uuid-2",
        "text": "Went to the park.",
        "timestamp": "2025-02-03T10:00:00Z"
      }
    ];
  }

  Future<Map<String, dynamic>> queryMemories(String query) async {
    // final response = await http.post(
    //   Uri.parse('$baseUrl/query'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'query': query}),
    // );
    
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return {
      "answer": "You felt happy and excited when you met Rahul at the cafe.",
      "sources": [
        {
          "text": "I met Rahul...",
          "timestamp": "2025-02-02T18:30:00Z"
        }
      ]
    };
  }
}
