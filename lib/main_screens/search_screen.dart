// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '/services/api_service.dart';
import '/models/movie.dart';
import 'detail_screen.dart';

// Search Screen widget
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  // Text editing controller for search query
  final TextEditingController _searchController = TextEditingController();
  // ApiService instance for fetching data
  final ApiService _apiService = ApiService();
  // Tab controller for switching between movie/TV show and actor search
  TabController? _tabController;

  // Lists to hold search results
  List<Movie> _searchResults = [];
  List<Movie> _actorSearchResults = [];

  // Speech to text instance for voice search
  stt.SpeechToText _speechToText = stt.SpeechToText();
  // Flag to track speech recognition availability
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize speech to text
    _initSpeech();
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
  }

  // Function to initialize speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print('Error: $val'), // Error handler
      onStatus: (val) => print('Status: $val'), // Status handler
    );
    setState(() {});
  }

  @override
  void dispose() {
    // Stop speech recognition
    _speechToText.stop();
    // Dispose tab controller
    _tabController?.dispose();
    super.dispose();
  }

  // Function to search content based on query
  void _searchContent(String query) async {
    if (query.isNotEmpty) {
      try {
        if (_tabController?.index == 0) {
          // Search for movies/TV shows
          final results = await _apiService.searchContent(query);
          setState(() {
            _searchResults = results;
          });
        } else if (_tabController?.index == 1) {
          // Search for actors
          final results = await _apiService.fetchMoviesByActorName(query);
          setState(() {
            _actorSearchResults = results;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _searchResults = [];
          _actorSearchResults = [];
        });
      }
    } else {
      setState(() {
        _searchResults = [];
        _actorSearchResults = [];
      });
    }
  }

  // Function to perform voice search
  void _listen() async {
    if (!_speechToText.isListening) {
      bool available = await _speechToText.listen(
        onResult: (val) => setState(() {
          _searchController.text = val.recognizedWords;
          _searchContent(val.recognizedWords);
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _searchContent,
          decoration: InputDecoration(
            hintText: 'Search Movies / TV Shows / Actors',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchContent('');
              },
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Movies / TV Shows'),
            Tab(text: 'Actors'),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
            onPressed: _speechEnabled ? _listen : null,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Widget for displaying movie/TV show search results
          ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) => _buildMovieTvShowTile(_searchResults[index]),
          ),
          // Widget for displaying actor search results
          ListView.builder(
            itemCount: _actorSearchResults.length,
            itemBuilder: (context, index) => _buildMovieTvShowTile(_actorSearchResults[index]),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  // Widget to build individual movie/TV show tiles
  Widget _buildMovieTvShowTile(Movie movie) {
    return ListTile(
      leading: movie.posterPath != null ? CircleAvatar(
        backgroundImage: NetworkImage(movie.imageUrl),
      ) : CircleAvatar(
        child: Icon(movie.isTV ? Icons.tv : Icons.movie, color: Colors.white),
        backgroundColor: Colors.grey,
      ),
      title: Text(
        movie.title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Release Date: ${movie.releaseDate ?? 'N/A'}',
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(movie: movie),
          ),
        );
      },
    );
  }
}
