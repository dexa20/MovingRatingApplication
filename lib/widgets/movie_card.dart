import 'package:flutter/material.dart';
import '/models/movie.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_database/firebase_database.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isInWatchlist = false;

  late final FirebaseDatabase database;

  @override
  void initState() {
    super.initState();

    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://dbtest-1117e-default-rtdb.firebaseio.com/", 
    );
    checkIfInWatchlist();
  }

  void checkIfInWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}');
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        setState(() {
          isInWatchlist = true;
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
      final dbRef = database.ref('watchlist/${user.uid}');
      await dbRef.push().set(movieData);
      setState(() {
        isInWatchlist = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added to watchlist!')));
    }
  }

  void removeFromWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}');
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> children =
            snapshot.value as Map<dynamic, dynamic>;
        String? keyToRemove;
        children.forEach((key, value) {
          if (value['id'] == widget.movie.id) {
            keyToRemove = key;
          }
        });
        if (keyToRemove != null) {
          await dbRef.child(keyToRemove!).remove();
          setState(() {
            isInWatchlist = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Removed from watchlist!')));
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
                widget.movie.imageUrl,
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
                    widget.movie.title,
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
                      backgroundColor:
                          isInWatchlist ? Colors.red : Colors.green,
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
