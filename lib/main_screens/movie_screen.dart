// Import necessary packages and files
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '/models/movie.dart';
import '/services/api_service.dart';
import '/widgets/movie_card.dart';
import 'detail_screen.dart';

// Class for the Movie Screen widget
class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  // Future for fetching movies
  late Future<List<Movie>> futureMovies;
  // Selected genre for filtering movies
  String selectedGenre = 'Popular Movies';
  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();
  // Timer for debouncing search queries
  Timer? _debounce;
  // Speech to text instance
  stt.SpeechToText _speechToText = stt.SpeechToText();
  // Flag to indicate if speech recognition is enabled
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch popular movies
    futureMovies = ApiService().fetchPopularMovies();
    // Initialize speech recognition
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose the search controller
    _searchController.dispose();
    // Cancel the debounce timer
    _debounce?.cancel();
    // Stop speech recognition
    _speechToText.stop();
    super.dispose();
  }

  // Fetch movies based on the provided genre or search query
  void _fetchMovies({String? genre, String? query}) {
    // Cancel the previous debounce timer if active
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // If a search query is provided, fetch movies matching the query
        if (query != null) {
          futureMovies = ApiService().searchMovies(query);
          selectedGenre = 'Search Results';
        } 
        // If a genre is provided, fetch movies of that genre
        else if (genre != null) {
          selectedGenre = genre;
          futureMovies = genre != 'Popular Movies'
              ? ApiService().fetchMoviesByGenre(genre)
              : ApiService().fetchPopularMovies();
        }
      });
    });
  }

  // Listen to speech input for search queries
  void _listen() async {
    if (!_speechToText.isListening) {
      bool available = await _speechToText.listen(
        onResult: (result) => setState(() {
          _searchController.text = result.recognizedWords;
          _fetchMovies(query: result.recognizedWords);
        }),
      );
      if (available) {
        setState(() {});
      }
    } else {
      _speechToText.stop();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine grid parameters based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 180;
    final crossAxisCount = (screenWidth ~/ cardWidth).clamp(2, 4);

    return Scaffold(
      // App bar
      appBar: AppBar(
        // Search field
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Movies...",
            suffixIcon: Icon(Icons.search),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (query) => _fetchMovies(query: query),
        ),
        backgroundColor: Colors.green,
        // Action buttons
        actions: <Widget>[
          // Microphone icon for speech input
          IconButton(
            icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
            onPressed: _speechEnabled ? _listen : null,
          ),
          // Dropdown menu for filtering movies by genre
          PopupMenuButton<String>(
            onSelected: (genre) {
              _searchController.clear();
              _fetchMovies(genre: genre);
            },
            itemBuilder: (BuildContext context) {
              // List of genres
              return [
                'Popular Movies',
                'Action',
                'Adventure',
                'Animation',
                'Comedy',
                'Crime',
                'Documentary',
                'Drama',
                'Family',
                'Fantasy',
                'History',
                'Horror',
                'Music',
                'Mystery',
                'Romance',
                'Science Fiction',
                'TV Movie',
                'Thriller',
                'War',
                'Western',
              ].map((String choice) {
                // Create a popup menu item for each genre
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      // Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected genre text
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                selectedGenre,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          // Movie grid
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: futureMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: (cardWidth / 260).clamp(0.5, 1),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // Create a movie card for each movie
                      Movie movie = snapshot.data![index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(movie: movie),
                          ),
                        ),
                        child: MovieCard(movie: movie),
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No Movies found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
