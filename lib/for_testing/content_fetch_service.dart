import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '/models/movie.dart'; // Update this path to your actual Movie model path

class ContentFetchService {
  final http.Client client;
  final String _apiKey = '695f4589f386f1202dcf4b4d7d87a9be';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  ContentFetchService({required this.client});

  Future<List<Movie>> fetchCinemaMovies() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
  }

  Future<List<Movie>> fetchTVAiringToday() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey'));
    return _parseMoviesResponse(response);
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
  // Add other methods here if needed

  List<Movie> _parseMoviesResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((result) => Movie.fromJson(result))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
