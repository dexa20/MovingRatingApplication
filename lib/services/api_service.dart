import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '/models/movie.dart';
import '/models/cast_member.dart';

// Class responsible for making API requests and handling responses
class ApiService {
  // API key and base URL for The Movie Database (TMDb) API
  final String _apiKey = '695f4589f386f1202dcf4b4d7d87a9be';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Method to fetch movies currently in cinemas
  Future<List<Movie>> fetchCinemaMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
  }

  // Method to fetch TV shows airing today
  Future<List<Movie>> fetchTVAiringToday() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey'));
    return _parseMoviesResponse(response, isTV: true);
  }

  // Method to fetch the best movies of the current year
  Future<List<Movie>> fetchBestMoviesOfYear() async {
    final year = DateTime.now().year;
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=vote_average.desc&year=$year'));
    return _parseMoviesResponse(response);
  }

  // Method to fetch the highest-grossing movies
  Future<List<Movie>> fetchHighestGrossingMovies() async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=revenue.desc'));
    return _parseMoviesResponse(response);
  }

  // Method to fetch trending movies
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'week'}) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
  }

  // Method to search for movies based on a query string
  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'));
    return _parseMoviesResponse(response);
  }

  // Method to search for TV shows based on a query string
  Future<List<Movie>> searchTVShows(String query) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'));
    return _parseMoviesResponse(response, isTV: true);
  }

  // Method to fetch details of a movie or TV show by its ID
  Future<Movie> fetchDetailsById(int id, bool isTV) async {
    final type = isTV ? 'tv' : 'movie';
    final response = await http.get(Uri.parse('$_baseUrl/$type/$id?api_key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data, isTV: isTV);
    } else {
      throw Exception('Failed to load details for id $id');
    }
  }

  // Method to fetch popular TV shows
  Future<List<Movie>> fetchPopularTVShows({int pageCount = 1}) async {
    List<Movie> allShows = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&page=$i'));
      allShows.addAll(_parseMoviesResponse(response, isTV: true));
    }
    return allShows;
  }

  // Method to fetch popular movies
  Future<List<Movie>> fetchPopularMovies({int pageCount = 1}) async {
    List<Movie> allMovies = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$i'));
      allMovies.addAll(_parseMoviesResponse(response));
    }
    return allMovies;
  }

  // Method to fetch TV shows by genre
  Future<List<Movie>> fetchTVShowsByGenre(String genreName, {int pageCount = 1}) async {
    int genreId = _getGenreIdByNameForTvShows(genreName);
    List<Movie> allShows = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse(
          '$_baseUrl/discover/tv?api_key=$_apiKey&with_genres=$genreId&page=$i'));
      allShows.addAll(_parseMoviesResponse(response, isTV: true));
    }
    return allShows;
  }

  // Method to fetch movies by genre
  Future<List<Movie>> fetchMoviesByGenre(String genreName, {int pageCount = 1}) async {
    int genreId = _getGenreIdByNameForMovies(genreName);
    List<Movie> allMovies = [];
    for (int i = 1; i <= pageCount; i++) {
      final response = await http.get(Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&page=$i'));
      allMovies.addAll(_parseMoviesResponse(response));
    }
    return allMovies;
  }

  // Method to search for movies and TV shows based on a query string
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

  // Method to fetch movies based on the name of an actor
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

  // Method to fetch cast details for a movie or TV show
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

  // Private method to parse movie or TV show data from API response
  List<Movie> _parseMoviesResponse(http.Response response, {bool isTV = false}) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((result) => Movie.fromJson(result, isTV: isTV))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Private method to get genre ID for movies based on genre name
  int _getGenreIdByNameForMovies(String genreName) {
    const Map<String, int> genreIds = {
      'Action': 28,
      'Adventure': 12,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Fantasy': 14,
      'History': 36,
      'Horror': 27,
      'Music': 10402,
      'Mystery': 9648,
      'Romance': 10749,
      'Science Fiction': 878,
      'TV Movie': 10770,
      'Thriller': 53,
      'War': 10752,
      'Western': 37,
    };
    return genreIds[genreName] ?? 0; // Returns 0 if genre name is not found
  }

  // Private method to get genre ID for TV shows based on genre name
  int _getGenreIdByNameForTvShows(String genreName) {
    const Map<String, int> genreIds = {
      'Action & Adventure': 10759,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Kids': 10762,
      'Mystery': 9648,
      'News': 10763,
      'Reality': 10764,
      'Science Fiction & Fantasy': 10765,
      'Soap': 10766,
      'Talk': 10767,
      'War & Politics': 10768,
      'Western': 37,
    };
    return genreIds[genreName] ?? 0; // Returns 0 if genre name is not found
  }
}
