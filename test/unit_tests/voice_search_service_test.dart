// Import necessary testing libraries
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Import the class being tested and its dependencies
import 'package:DM_Flix/for_testing/voice_search_service.dart';
import 'package:DM_Flix/models/mock_movie.dart';

// Define mock implementations for dependencies
class MockSpeechToTextService extends Mock implements SpeechToTextService {}
class MockSearchService extends Mock implements SearchService {}

// Main test function
void main() {
  // Test group for the VoiceSearchService class
  group('VoiceSearchService', () {
    // Test case: performs a search with recognized text
    test('performs a search with recognized text', () async {
      // Create mock instances for dependencies
      final mockSpeechToTextService = MockSpeechToTextService();
      final mockSearchService = MockSearchService();

      // Create an instance of the class under test, passing in the mock dependencies
      final voiceSearchService = VoiceSearchService(
        speechToTextService: mockSpeechToTextService,
        searchService: mockSearchService,
      );

      // Create mock movie data and an expected query string
      final movies = [MockMovie(title: 'Test Movie')];
      final String expectedQuery = 'Test Query';

      // Setup mocks with explicit argument
      // Mock behavior for the speech to text service to return the expected query string
      when(mockSpeechToTextService.listenAndGetText()).thenAnswer((_) async => expectedQuery);
      // Mock behavior for the search service to return the mock movie data
      when(mockSearchService.search(expectedQuery)).thenAnswer((_) async => movies);

      // Call the method being tested
      final result = await voiceSearchService.voiceSearch();

      // Verify that the search was performed with the specific recognized text
      verify(mockSpeechToTextService.listenAndGetText()).called(1);
      verify(mockSearchService.search(expectedQuery)).called(1);

      // Check the result of the test case matches the expected movie data
      expect(result, equals(movies));
    });
  });
}
