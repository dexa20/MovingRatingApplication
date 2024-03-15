import 'package:flutter/material.dart'; // Flutter UI framework
import '/models/movie.dart'; // Movie model
import '/services/api_service.dart'; // API service for fetching data
import '/widgets/movie_card.dart'; // Widget for displaying movie card
import 'detail_screen.dart'; // Screen for displaying movie details
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Firebase Core functionality

// Class for the Watchlist Screen widget
class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  late final FirebaseDatabase _database; // Firebase Realtime Database instance
  late Future<List<Movie>> futureWatchlistItems; // Future for fetching watchlist items
  bool _displayTVShows = false; // New state variable to toggle display

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Realtime Database
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://dbtest-1117e-default-rtdb.firebaseio.com/",
    );
    // Fetch watchlist items
    futureWatchlistItems = _fetchWatchlistItems();
  }

  // Fetch watchlist items from Firebase Realtime Database
  Future<List<Movie>> _fetchWatchlistItems() async {
    final user = _auth.currentUser; // Get current user
    if (user == null) throw Exception('User not logged in'); // Ensure user is logged in
    final dbRef = _database.ref('watchlist/${user.uid}'); // Database reference
    final snapshot = await dbRef.get(); // Get snapshot of watchlist data

    List<Movie> items = []; // List to store watchlist items
    if (snapshot.exists) {
      for (var child in snapshot.children) {
        final itemData = child.value as Map<dynamic, dynamic>; // Extract item data
        final int id = itemData['id']; // Extract item ID
        final bool isTV = itemData['isTV'] ?? false; // Determine if item is a TV show
        if (isTV == _displayTVShows) {
          try {
            final item = await ApiService().fetchDetailsById(id, isTV); // Fetch item details
            items.add(item); // Add item to list
          } catch (e) {
            print("Error fetching details: $e"); // Handle error fetching details
          }
        }
      }
    }
    return items; // Return list of watchlist items
  }

  // Toggle between displaying movies and TV shows
  void _toggleDisplayMode() {
    setState(() {
      _displayTVShows = !_displayTVShows; // Toggle display mode
      futureWatchlistItems = _fetchWatchlistItems(); // Fetch updated watchlist items
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        title: Text(
          "Watchlist",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: <Widget>[
          // Button to toggle display mode
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _toggleDisplayMode,
          ),
        ],
      ),
      // Body
      body: Column(
        children: [
          // Container for displaying current display mode (Movies or TV Shows)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[900], // Background color
            width: double.infinity, // Full width
            child: Text(
              _displayTVShows ? 'TV Shows' : 'Movies', // Display mode text
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Watchlist items grid
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: futureWatchlistItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while data is being fetched
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Display error message if fetching data fails
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Display grid of watchlist items if data is available
                  return GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items per row
                      childAspectRatio: 0.6, // Aspect ratio of grid items
                      crossAxisSpacing: 10, // Spacing between items horizontally
                      mainAxisSpacing: 10, // Spacing between items vertically
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // Create a card for each watchlist item
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
                  // Display message if no items in watchlist
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
