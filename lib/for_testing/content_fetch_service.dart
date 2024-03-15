import 'dart:convert'; // Importing dart:convert library for JSON parsing
import 'dart:async'; // Importing dart:async library for asynchronous operations
import 'package:http/http.dart' as http; // Importing http library for making HTTP requests
import '/models/movie.dart'; // Importing movie model

class ContentFetchService {
  final http.Client client; // HTTP client for making requests
  final String _apiKey = '695f4589f386f1202dcf4b4d7d87a9be'; // API key for accessing TMDB API
  final String _baseUrl = 'https://api.themoviedb.org/3'; // Base URL for TMDB API

  ContentFetchService({required this.client}); // Constructor for ContentFetchService

  // Method to fetch movies currently playing in cinema
  Future<List<Movie>> fetchCinemaMovies() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey')); // Making HTTP GET request
    return _parseMoviesResponse(response); // Parsing response
  }

  // Method to fetch TV shows airing today
  Future<List<Movie>> fetchTVAiringToday() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey')); // Making HTTP GET request
    return _parseMoviesResponse(response); // Parsing response
  }

  // Method to fetch best movies of the year
  Future<List<Movie>> fetchBestMoviesOfYear() async {
    final year = DateTime.now().year; // Getting current year
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=vote_average.desc&year=$year')); // Making HTTP GET request
    return _parseMoviesResponse(response); // Parsing response
  }

  // Method to fetch highest grossing movies
  Future<List<Movie>> fetchHighestGrossingMovies() async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&sort_by=revenue.desc')); // Making HTTP GET request
    return _parseMoviesResponse(response); // Parsing response
  }

  // Method to fetch trending movies
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'week'}) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey')); // Making HTTP GET request
    return _parseMoviesResponse(response); // Parsing response
  }
  // Add other methods here if needed

  // Method to parse movies response
  List<Movie> _parseMoviesResponse(http.Response response) {
    if (response.statusCode == 200) { // If response is successful
      final data = json.decode(response.body); // Decode JSON data
      return (data['results'] as List) // Mapping JSON data to list of Movie objects
          .map((result) => Movie.fromJson(result))
          .toList();
    } else {
      throw Exception('Failed to load data'); // Throw exception if failed to load data
    }
  }
}
