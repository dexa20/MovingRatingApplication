// Importing movie model
import '/models/movie.dart';

// Abstract class for speech-to-text service
abstract class SpeechToTextService {
  Future<String?> listenAndGetText(); // Method to listen for voice input and return text
}

// Abstract class for search service
abstract class SearchService {
  Future<List<Movie>> search(String query); // Method to search for movies based on query
}

// Class for voice search service
class VoiceSearchService {
  final SpeechToTextService speechToTextService; // Speech-to-text service instance
  final SearchService searchService; // Search service instance

  // Constructor for VoiceSearchService
  VoiceSearchService({required this.speechToTextService, required this.searchService});

  // Method to perform voice search
  Future<List<Movie>?> voiceSearch() async {
    final query = await speechToTextService.listenAndGetText(); // Get voice input as text
    if (query != null && query.isNotEmpty) { // Check if query is not empty
      return searchService.search(query); // Perform search based on query
    }
    return null; // Return null if query is empty
  }
}
