import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '/models/movie.dart';
import '/models/cast_member.dart';

class ApiService {
  final String _apiKey = '695f4589f386f1202dcf4b4d7d87a9be';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchCinemaMovies() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> fetchTVAiringToday() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey'));
    return _parseMoviesResponse(response, isTV: true);
  }

  Future<List<Movie>> fetchBestMoviesOfYear() async {
    final year = DateTime.now().year;
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=vote_average.desc&year=$year'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> fetchHighestGrossingMovies() async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=revenue.desc'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'week'}) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> searchTVShows(String query) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'));
    return _parseMoviesResponse(response, isTV: true);
  }

  Future<Movie> fetchDetailsById(int id, bool isTV) async {
    final type = isTV ? 'tv' : 'movie';
    final response =
        await http.get(Uri.parse('$_baseUrl/$type/$id?api_key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data, isTV: isTV);
    } else {
      throw Exception('Failed to load details for id $id');
    }
  }

  Future<List<Movie>> fetchPopularTVShows({int pageCount = 1}) async {
    List<Movie> allShows = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http
          .get(Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&page=$i'));
      allShows.addAll(_parseMoviesResponse(response, isTV: true));
    }
    return allShows;
  }

  Future<List<Movie>> fetchPopularMovies({int pageCount = 1}) async {
    List<Movie> allMovies = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http
          .get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$i'));
      allMovies.addAll(_parseMoviesResponse(response));
    }
    return allMovies;
  }

  Future<List<Movie>> fetchTVShowsByGenre(String genreName,
      {int pageCount = 1}) async {
    int genreId = _getGenreIdByNameForTvShows(genreName);
    List<Movie> allShows = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse(
          '$_baseUrl/discover/tv?api_key=$_apiKey&with_genres=$genreId&page=$i'));
      allShows.addAll(_parseMoviesResponse(response, isTV: true));
    }
    return allShows;
  }

  Future<List<Movie>> fetchMoviesByGenre(String genreName,
      {int pageCount = 1}) async {
    int genreId = _getGenreIdByNameForMovies(genreName);
    List<Movie> allMovies = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&page=$i'));
      allMovies.addAll(_parseMoviesResponse(response));
    }
    return allMovies;
  }

  Future<List<Movie>> searchContent(String query) async {
    var movieSearchUrl = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}');
    var tvShowSearchUrl = Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(query)}');

    try {
      final responses = await Future.wait([
        http.get(movieSearchUrl),
        http.get(tvShowSearchUrl),
      ]);

      List<Movie> movies = _parseMoviesResponse(responses[0]);
      List<Movie> tvShows = _parseMoviesResponse(responses[1], isTV: true);
      return [...movies, ...tvShows];
    } catch (e) {
      print('Error searching content: $e');
      return [];
    }
  }

  Future<List<Movie>> fetchMoviesByActorName(String actorName) async {
    final searchResponse = await http.get(Uri.parse(
        '$_baseUrl/search/person?api_key=$_apiKey&query=${Uri.encodeComponent(actorName)}'));

    if (searchResponse.statusCode == 200) {
      final searchData = json.decode(searchResponse.body);
      final List<dynamic> results = searchData['results'];

      if (results.isNotEmpty) {
        final actorId = results[0]['id'];

        final movieResponse = await http.get(Uri.parse(
            '$_baseUrl/discover/movie?api_key=$_apiKey&with_cast=$actorId'));

        if (movieResponse.statusCode == 200) {
          return _parseMoviesResponse(movieResponse);
        } else {
          throw Exception('Failed to load movies for actor');
        }
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to search for actor');
    }
  }

  // Add the new method for fetching the cast details
  Future<List<CastMember>> fetchCast(int id, bool isTV) async {
    final type = isTV ? 'tv' : 'movie';
    final url = Uri.parse('$_baseUrl/$type/$id/credits?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> castJson = data['cast'];
      List<CastMember> cast =
          castJson.map((json) => CastMember.fromJson(json)).toList();
      return cast;
    } else {
      throw Exception('Failed to load cast information');
    }
  }

  List<Movie> _parseMoviesResponse(http.Response response,
      {bool isTV = false}) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((result) => Movie.fromJson(result, isTV: isTV))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  int _getGenreIdByNameForMovies(String genreName) {
    const Map<String, int> genreIds = {
      'Action': 28,
      'Drama': 18,
      'Comedy': 35,
      'Family/Kids': 10751,
    };
    return genreIds[genreName] ?? 0;
  }

  int _getGenreIdByNameForTvShows(String genreName) {
    const Map<String, int> genreIds = {
      'Action': 10759,
      'Drama': 18,
      'Comedy': 35,
      'Family/Kids': 10751,
    };
    return genreIds[genreName] ?? 0;
  }
}
