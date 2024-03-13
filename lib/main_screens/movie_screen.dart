import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '/models/movie.dart';
import '/services/api_service.dart';
import '/widgets/movie_card.dart';
import 'detail_screen.dart';

class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late Future<List<Movie>> futureMovies;
  String selectedGenre = 'Popular Movies';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService().fetchPopularMovies();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _speechToText.stop();
    super.dispose();
  }

  void _fetchMovies({String? genre, String? query}) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        if (query != null) {
          futureMovies = ApiService().searchMovies(query);
          selectedGenre = 'Search Results';
        } else if (genre != null) {
          selectedGenre = genre;
          futureMovies = genre != 'Popular Movies'
              ? ApiService().fetchMoviesByGenre(genre)
              : ApiService().fetchPopularMovies();
        }
      });
    });
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 180;
    final crossAxisCount = (screenWidth ~/ cardWidth).clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
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
        actions: <Widget>[
          IconButton(
            icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
            onPressed: _speechEnabled ? _listen : null,
          ),
          PopupMenuButton<String>(
            onSelected: (genre) {
              _searchController.clear();
              _fetchMovies(genre: genre);
            },
            itemBuilder: (BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
