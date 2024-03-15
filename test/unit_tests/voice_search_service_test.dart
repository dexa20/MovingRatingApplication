// test/voice_search_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:DM_Flix/for_testing/voice_search_service.dart';
import 'package:DM_Flix/models/mock_movie.dart';

class MockSpeechToTextService extends Mock implements SpeechToTextService {}

class MockSearchService extends Mock implements SearchService {}



void main() {
  group('VoiceSearchService', () {
    test('performs a search with recognized text', () async {
      final mockSpeechToTextService = MockSpeechToTextService();
      final mockSearchService = MockSearchService();
      final voiceSearchService = VoiceSearchService(
        speechToTextService: mockSpeechToTextService,
        searchService: mockSearchService,
      );
      final movies = [MockMovie(title: 'Test Movie')];
      final String expectedQuery = 'Test Query';

      // Setup mocks with explicit argument
      when(mockSpeechToTextService.listenAndGetText()).thenAnswer((_) async => expectedQuery);
      when(mockSearchService.search(expectedQuery)).thenAnswer((_) async => movies);

      final result = await voiceSearchService.voiceSearch();

      // Verify the search was performed with the specific recognized text
      verify(mockSpeechToTextService.listenAndGetText()).called(1);
      verify(mockSearchService.search(expectedQuery)).called(1);
      expect(result, equals(movies));
    });
  });
}
