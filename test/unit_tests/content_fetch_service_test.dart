import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:DM_Flix/for_testing/content_fetch_service.dart';
import 'package:DM_Flix/models/movie.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('ContentFetchService', () {
    late MockClient client;
    late ContentFetchService service;
    late List<Movie> mockMovies;

    setUp(() {
      client = MockClient();
      service = ContentFetchService(client: client);
      mockMovies = [Movie.fromJson({
        "id": 1,
        "title": "Mock Movie",
        "overview": "Mock overview",
        "poster_path": "/mockPoster.jpg",
        "vote_average": 8.5,
        "release_date": "2021-01-01",
        "isTV": false,
      })];
    });

    test('fetchCinemaMovies returns a list of movies', () async {
      when(client.get(Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchCinemaMovies();

      expect(result, isA<List<Movie>>());
      expect(result.length, equals(mockMovies.length));
      expect(result[0].title, equals(mockMovies[0].title));
    });

    test('fetchTVAiringToday returns a list of TV shows', () async {
      when(client.get(Uri.parse('https://api.themoviedb.org/3/tv/airing_today?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchTVAiringToday();

      expect(result, isA<List<Movie>>());
      expect(result[0].isTV, equals(true)); // Assuming your toJson adjusts for TV shows
    });

    test('fetchBestMoviesOfYear returns a list of movies', () async {
      final year = DateTime.now().year;
      when(client.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=695f4589f386f1202dcf4b4d7d87a9be&sort_by=vote_average.desc&year=$year')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchBestMoviesOfYear();

      expect(result, isA<List<Movie>>());
    });

    test('fetchHighestGrossingMovies returns a list of movies', () async {
      when(client.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=695f4589f386f1202dcf4b4d7d87a9be&sort_by=revenue.desc')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchHighestGrossingMovies();

      expect(result, isA<List<Movie>>());
    });

    test('fetchTrendingMovies returns a list of movies', () async {
      const timeWindow = 'week';
      when(client.get(Uri.parse('https://api.themoviedb.org/3/trending/movie/$timeWindow?api_key=695f4589f386f1202dcf4b4d7d87a9be')))
          .thenAnswer((_) async => http.Response(jsonEncode({"results": mockMovies.map((m) => m.toJson()).toList()}), 200));

      final result = await service.fetchTrendingMovies(timeWindow: timeWindow);

      expect(result, isA<List<Movie>>());
    });
  });
}
