// lib/for_testing/voice_search_service.dart
import '/models/movie.dart';

abstract class SpeechToTextService {
  Future<String?> listenAndGetText();
}

abstract class SearchService {
  Future<List<Movie>> search(String query);
}

class VoiceSearchService {
  final SpeechToTextService speechToTextService;
  final SearchService searchService;

  VoiceSearchService({required this.speechToTextService, required this.searchService});

  Future<List<Movie>?> voiceSearch() async {
    final query = await speechToTextService.listenAndGetText();
    if (query != null && query.isNotEmpty) {
      return searchService.search(query);
    }
    return null;
  }
}
