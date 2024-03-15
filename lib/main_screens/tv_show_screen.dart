// Import necessary packages and files
import 'dart:async'; // For asynchronous operations
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:speech_to_text/speech_to_text.dart' as stt; // Speech to text library
import '/models/movie.dart'; // Movie model
import '/services/api_service.dart'; // API service for fetching data
import '/widgets/movie_card.dart'; // Widget for displaying movie card
import 'detail_screen.dart'; // Screen for displaying movie details

// Class for the TV Show Screen widget
class TVShowScreen extends StatefulWidget {
  @override
  _TVShowScreenState createState() => _TVShowScreenState();
}

class _TVShowScreenState extends State<TVShowScreen> {
  // Future for fetching TV shows
  late Future<List<Movie>> futureTVShows;
  // Selected genre for filtering TV shows
  String selectedGenre = 'Popular TV Shows';
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
    // Initialize the future to fetch popular TV shows
    futureTVShows = ApiService().fetchPopularTVShows();
    // Initialize speech recognition
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    // Initialize speech to text and update speechEnabled flag
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print("SpeechToText error: $error"),
      onStatus: (status) => print("SpeechToText status: $status"),
    );
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

  // Fetch TV shows based on the provided genre or search query
  void _fetchTVShows({String? genre, String? query}) {
    // Cancel the previous debounce timer if active
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // If a search query is provided, fetch TV shows matching the query
        if (query != null) {
          futureTVShows = ApiService().searchTVShows(query);
          selectedGenre = 'Search Results';
        }
        // If a genre is provided, fetch TV shows of that genre
        else if (genre != null) {
          selectedGenre = genre;
          futureTVShows = genre != 'Popular TV Shows'
              ? ApiService().fetchTVShowsByGenre(genre)
              : ApiService().fetchPopularTVShows();
        }
      });
    });
  }

  // Listen to speech input for search queries
  void _listen() async {
    // Check if speech to text is not already listening
    if (!_speechToText.isListening) {
      // Start listening and update search controller with recognized words
      bool available = await _speechToText.listen(
        onResult: (result) => setState(() {
          _searchController.text = result.recognizedWords;
          _fetchTVShows(query: result.recognizedWords);
        }),
      );
      // If speech recognition is available, update state
      if (!available) {
        setState(() => _speechEnabled = false);
      }
    } else {
      // Stop speech recognition if already listening
      _speechToText.stop();
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
            hintText: "Search TV Shows...",
            suffixIcon: Icon(Icons.search),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (query) => _fetchTVShows(query: query),
        ),
        backgroundColor: Colors.green,
        // Action buttons
        actions: <Widget>[
          // Microphone icon for speech input
          IconButton(
            icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
            onPressed: _speechEnabled ? _listen : null,
          ),
          // Dropdown menu for filtering TV shows by genre
          PopupMenuButton<String>(
            onSelected: (genre) {
              _searchController.clear();
              _fetchTVShows(genre: genre);
            },
            itemBuilder: (BuildContext context) {
              // List of genres
              return [
                'Popular TV Shows',
                'Action & Adventure',
                'Animation',
                'Comedy',
                'Crime',
                'Documentary',
                'Drama',
                'Family',
                'Kids',
                'Mystery',
                'News',
                'Reality',
                'Science Fiction & Fantasy',
                'Soap',
                'Talk',
                'War & Politics',
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                selectedGenre,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          // TV show grid
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: futureTVShows,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while data is being fetched
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Display error message if fetching data fails
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Display grid of TV shows if data is available
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
                      // Create a TV show card for each TV show
                      Movie tvShow = snapshot.data![index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(movie: tvShow),
                          ),
                        ),
                        child: MovieCard(movie: tvShow),
                      );
                    },
                  );
                } else {
                  // Display message if no TV shows are found
                  return Center(child: Text("No TV Shows found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
