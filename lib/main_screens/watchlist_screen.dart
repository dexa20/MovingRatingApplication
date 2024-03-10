import 'package:flutter/material.dart';
import '/models/movie.dart';
import '/services/api_service.dart';
import '/widgets/movie_card.dart';
import 'detail_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseDatabase _database;
  late Future<List<Movie>> futureWatchlistItems;
  bool _displayTVShows = false; // New state variable to toggle display

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://dbtest-1117e-default-rtdb.firebaseio.com/",
    );
    futureWatchlistItems = _fetchWatchlistItems();
  }

  Future<List<Movie>> _fetchWatchlistItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final dbRef = _database.ref('watchlist/${user.uid}');
    final snapshot = await dbRef.get();

    List<Movie> items = [];
    if (snapshot.exists) {
      for (var child in snapshot.children) {
        final itemData = child.value as Map<dynamic, dynamic>;
        final int id = itemData['id'];
        final bool isTV = itemData['isTV'] ?? false;
        if (isTV == _displayTVShows) {
          try {
            final item = await ApiService().fetchDetailsById(id, isTV);
            items.add(item);
          } catch (e) {
            print("Error fetching details: $e");
          }
        }
      }
    }
    return items;
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayTVShows = !_displayTVShows;
      futureWatchlistItems =
          _fetchWatchlistItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Watchlist",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _toggleDisplayMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors
                .grey[900], 
            width: double
                .infinity, 
            child: Text(
              _displayTVShows ? 'TV Shows' : 'Movies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors
                    .white, 
              ),
              textAlign: TextAlign
                  .center, 
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: futureWatchlistItems,
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
                  return Center(child: Text("No items in watchlist"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
