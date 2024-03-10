import 'package:flutter/material.dart';
import '/models/movie.dart'; // Ensure these imports point to the correct files
import '/services/api_service.dart';
import '/widgets/movie_card.dart';
import 'detail_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is initialized in your app

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseDatabase _database; // Declare _database here
  late Future<List<Movie>> futureWatchlistMovies;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://dbtest-1117e-default-rtdb.firebaseio.com/", // Replace with your actual Firebase Realtime Database URL
    );
    futureWatchlistMovies = _fetchWatchlistMovies();
  }

  Future<List<Movie>> _fetchWatchlistMovies() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final dbRef = _database.ref('watchlist/${user.uid}');
    final snapshot = await dbRef.get();

    List<Movie> movies = [];
    if (snapshot.exists) {
      for (var child in snapshot.children) {
        final movieData = child.value as Map<dynamic, dynamic>;
        final int id = movieData['id'];
        final bool isTV = movieData['isTV'] ?? false;
        try {
          final movie = await ApiService().fetchDetailsById(
              id, isTV); // Ensure this method exists in your ApiService
          movies.add(movie);
        } catch (e) {
          print("Error fetching details: $e");
        }
      }
    }
    return movies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watchlist"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureWatchlistMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
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
            return Center(child: Text("No movies in watchlist"));
          }
        },
      ),
    );
  }
}
