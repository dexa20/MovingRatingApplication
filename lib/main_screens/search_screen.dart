import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '/services/api_service.dart';
import '/models/movie.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  TabController? _tabController;

  List<Movie> _searchResults = [];
  List<Movie> _actorSearchResults = [];

  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: (val) => print('Status: $val'),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _speechToText.stop();
    _tabController?.dispose();
    super.dispose();
  }

  void _searchContent(String query) async {
    if (query.isNotEmpty) {
      try {
        if (_tabController?.index == 0) { // Movies/TV Shows tab
          final results = await _apiService.searchContent(query);
          setState(() {
            _searchResults = results;
          });
        } else if (_tabController?.index == 1) { // Actors tab
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.listen(
        onResult: (val) => setState(() {
          _searchController.text = val.recognizedWords;
          _searchContent(val.recognizedWords);
        }),
      );
      if (available) {
        setState(() => _isListening = true);
      }
    } else {
      _speechToText.stop();
      setState(() => _isListening = false);
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
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _speechEnabled ? _listen : null,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Movies/TV Shows search results
          ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) => _buildMovieTvShowTile(_searchResults[index]),
          ),
          // Actor search results
          ListView.builder(
            itemCount: _actorSearchResults.length,
            itemBuilder: (context, index) => _buildMovieTvShowTile(_actorSearchResults[index]),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }

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
