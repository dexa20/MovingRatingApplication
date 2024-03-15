import 'package:flutter/material.dart'; // Importing Flutter material library
import '/models/movie.dart'; // Importing movie model
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication library
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core library
import 'package:firebase_database/firebase_database.dart'; // Importing Firebase Realtime Database library

class MovieCard extends StatefulWidget { // StatefulWidget for displaying movie details
  final Movie movie; // Movie object to display details

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isInWatchlist = false; // Flag to track if movie is in user's watchlist

  late final FirebaseDatabase database; // Firebase database instance

  @override
  void initState() {
    super.initState();

    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://dbtest-1117e-default-rtdb.firebaseio.com/", // Firebase database URL
    );
    checkIfInWatchlist(); // Check if movie is in user's watchlist
  }

  void checkIfInWatchlist() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}'); // Reference to user's watchlist
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get(); // Get snapshot of movie in watchlist
      if (snapshot.exists) { // Check if movie exists in watchlist
        setState(() {
          isInWatchlist = true; // Set isInWatchlist flag to true if movie is in watchlist
        });
      }
    }
  }

  void addToWatchlist() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final movieData = {
        'id': widget.movie.id, // Movie ID
        'isTV': widget.movie.isTV, // Flag indicating if it's a TV show
      };
      final dbRef = database.ref('watchlist/${user.uid}'); // Reference to user's watchlist
      await dbRef.push().set(movieData); // Add movie to user's watchlist
      setState(() {
        isInWatchlist = true; // Update isInWatchlist flag
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added to watchlist!'))); // Show confirmation message
    }
  }

  void removeFromWatchlist() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}'); // Reference to user's watchlist
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get(); // Get snapshot of movie in watchlist
      if (snapshot.exists) { // Check if movie exists in watchlist
        Map<dynamic, dynamic> children =
            snapshot.value as Map<dynamic, dynamic>; // Extract children from snapshot
        String? keyToRemove;
        children.forEach((key, value) {
          if (value['id'] == widget.movie.id) {
            keyToRemove = key; // Get key of movie to remove from watchlist
          }
        });
        if (keyToRemove != null) {
          await dbRef.child(keyToRemove!).remove(); // Remove movie from watchlist
          setState(() {
            isInWatchlist = false; // Update isInWatchlist flag
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Removed from watchlist!'))); // Show confirmation message
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade800, Colors.grey.shade900],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Image.network(
                widget.movie.imageUrl, // Movie image URL
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200]!,
                  child: Icon(Icons.error, color: Colors.red[300], size: 50),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.movie.title, // Movie title
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.yellow[700], size: 20), // Star icon for rating
                      SizedBox(width: 4),
                      Text(
                        '${widget.movie.rating?.toStringAsFixed(1) ?? 'N/A'}', // Movie rating
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isInWatchlist ? Colors.red : Colors.green, // Button color based on watchlist status
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (isInWatchlist) {
                        removeFromWatchlist(); // Remove movie from watchlist
                      } else {
                        addToWatchlist(); // Add movie to watchlist
                      }
                    },
                    child: Text(isInWatchlist ? '- Watchlist' : '+ Watchlist'), // Button label
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
