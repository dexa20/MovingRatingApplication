import 'package:flutter_test/flutter_test.dart'; // Importing Flutter test library
import 'package:mockito/mockito.dart'; // Importing Mockito library for mocking objects
import 'package:http/http.dart' as http; // Importing http library for making HTTP requests
import 'dart:convert'; // Importing dart:convert library for JSON parsing
import 'package:DM_Flix/for_testing/content_fetch_service.dart'; // Importing content fetch service for testing
import 'package:DM_Flix/models/movie.dart'; // Importing movie model

// Mocking HTTP client for testing
class MockClient extends Mock implements http.Client {}

void main() {
  group('ContentFetchService', () {
    late MockClient client; // Mock HTTP client
    late ContentFetchService service; // Content fetch service
    late List<Movie> mockMovies; // Mock list of movies

    setUp(() {
      client = MockClient(); // Creating mock HTTP client
      service = ContentFetchService(client: client); // Creating content fetch service instance
      mockMovies = [Movie.fromJson({
        "id": 1,
        "title": "Mock Movie",
        "overview": "Mock overview",
        "poster_path": "/mockPoster.jpg",
        "vote_average": 8.5,
        "release_date": "2021-01-01",
        "isTV": false,
      })]; // Creating mock movie data
    });

    test('fetchCinemaMovies returns a list of movies', () async {
      // Mocking HTTP GET request and response
      when(client.get(Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchCinemaMovies(); // Calling fetchCinemaMovies method

      // Assertions
      expect(result, isA<List<Movie>>());
      expect(result.length, equals(mockMovies.length));
      expect(result[0].title, equals(mockMovies[0].title));
    });

    test('fetchTVAiringToday returns a list of TV shows', () async {
      // Mocking HTTP GET request and response
      when(client.get(Uri.parse('https://api.themoviedb.org/3/tv/airing_today?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchTVAiringToday(); // Calling fetchTVAiringToday method

      // Assertions
      expect(result, isA<List<Movie>>());
      expect(result[0].isTV, equals(true)); // Assuming your toJson adjusts for TV shows
    });

    test('fetchBestMoviesOfYear returns a list of movies', () async {
      final year = DateTime.now().year; // Getting current year
      // Mocking HTTP GET request and response
      when(client.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=695f4589f386f1202dcf4b4d7d87a9be&sort_by=vote_average.desc&year=$year')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchBestMoviesOfYear(); // Calling fetchBestMoviesOfYear method

      // Assertions
      expect(result, isA<List<Movie>>());
    });

    test('fetchHighestGrossingMovies returns a list of movies', () async {
      // Mocking HTTP GET request and response
      when(client.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=695f4589f386f1202dcf4b4d7d87a9be&sort_by=revenue.desc')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchHighestGrossingMovies(); // Calling fetchHighestGrossingMovies method

      // Assertions
      expect(result, isA<List<Movie>>());
    });

    test('fetchTrendingMovies returns a list of movies', () async {
      const timeWindow = 'week'; // Time window for trending movies
      // Mocking HTTP GET request and response
      when(client.get(Uri.parse('https://api.themoviedb.org/3/trending/movie/$timeWindow?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchTrendingMovies(timeWindow: timeWindow); // Calling fetchTrendingMovies method

      // Assertions
      expect(result, isA<List<Movie>>());
    });
  });
}
