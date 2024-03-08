import 'package:flutter/material.dart';
import '/models/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isInWatchlist = false; // State to track if the movie is in the watchlist

  @override
  void initState() {
    super.initState();
    checkIfInWatchlist(); // Check if the movie is in the watchlist on widget initialization
  }

  void checkIfInWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref('watchlist/${user.uid}');
      final snapshot = await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        setState(() {
          isInWatchlist = true; // Update the state based on the database check
        });
      }
    }
  }

  void addToWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final movieData = {
        'id': widget.movie.id,
        'isTV': widget.movie.isTV,
      };
      final dbRef = FirebaseDatabase.instance.ref('watchlist/${user.uid}');
      await dbRef.push().set(movieData);
      setState(() {
        isInWatchlist = true; // Update state to reflect addition
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to watchlist!')));
    }
  }

  void removeFromWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref('watchlist/${user.uid}');
      // Query to find the specific movie in the watchlist
      final snapshot = await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        String? keyToRemove;
        Map<dynamic, dynamic> children = snapshot.value as Map<dynamic, dynamic>;
        // Iterate over the children to find the key of the movie to remove
        children.forEach((key, value) {
          if (value['id'] == widget.movie.id) {
            keyToRemove = key; // Capture the key of the movie to remove
          }
        });

        // Ensure keyToRemove is not null before proceeding with removal
        if (keyToRemove != null) {
          // Use the null assertion operator '!' to assert that keyToRemove is not null
          await dbRef.child(keyToRemove!).remove(); // Directly remove the movie using its key
          setState(() {
            isInWatchlist = false; // Update state to reflect the removal
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from watchlist!')));
        } else {
          // This else block might be redundant due to the null check above, but it's here for clarity
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing movie from watchlist.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Movie not found in watchlist.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You need to be logged in to manage your watchlist')));
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
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
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
                widget.movie.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
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
                    widget.movie.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.yellow[700], size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${widget.movie.rating?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInWatchlist ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (isInWatchlist) {
                        removeFromWatchlist();
                      } else {
                        addToWatchlist();
                      }
                    },
                    child: Text(isInWatchlist ? '- Watchlist' : '+ Watchlist'),
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
