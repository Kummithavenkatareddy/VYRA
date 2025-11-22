class MemoryCreate {
  final String text;
  final String? tone;

  MemoryCreate({required this.text, this.tone = "neutral"});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'tone': tone,
    };
  }
}

class MemoryResponse {
  final String memoryId;
  final String status;
  final String? message;

  MemoryResponse({required this.memoryId, required this.status, this.message});

  factory MemoryResponse.fromJson(Map<String, dynamic> json) {
    return MemoryResponse(
      memoryId: json['memory_id'] ?? '',
      status: json['status'] ?? '',
      message: json['message'],
    );
  }
}

class TimelineResponse {
  final String id;
  final String text;
  final String tone;
  final String date;
  final String time;

  TimelineResponse({
    required this.id,
    required this.text,
    required this.tone,
    required this.date,
    required this.time,
  });

  factory TimelineResponse.fromJson(Map<String, dynamic> json) {
    return TimelineResponse(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      tone: json['tone'] ?? 'neutral',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class QueryRequest {
  final String query;

  QueryRequest({required this.query});

  Map<String, dynamic> toJson() {
    return {
      'query': query,
    };
  }
}

class QueryResponse {
  final String answer;
  final List<TimelineResponse> usedMemories;

  QueryResponse({required this.answer, required this.usedMemories});

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['used_memories'] as List? ?? [];
    List<TimelineResponse> memoriesList =
        list.map((i) => TimelineResponse.fromJson(i)).toList();

    return QueryResponse(
      answer: json['answer'] ?? '',
      usedMemories: memoriesList,
    );
  }
}
