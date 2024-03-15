// Import necessary packages and files
import 'package:flutter/material.dart';
import '/models/movie.dart';
import '/models/cast_member.dart';
import '/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

// Class for the detail screen widget
class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // State variables
  bool isInWatchlist = false;
  late final FirebaseDatabase database;
  List<CastMember> cast = [];

  @override
  void initState() {
    super.initState();
    // Initialize Firebase database
    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://dbtest-1117e-default-rtdb.firebaseio.com/",
    );
    // Check if the movie is in the user's watchlist
    checkIfInWatchlist();
    // Fetch cast details
    fetchCastDetails();
  }

  // Function to check if the movie is in the user's watchlist
  void checkIfInWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}');
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      setState(() {
        isInWatchlist = snapshot.exists;
      });
    }
  }

  // Function to add movie to watchlist
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

  // Function to remove movie from watchlist
  void removeFromWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = database.ref('watchlist/${user.uid}');
      final snapshot =
          await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> children =
            snapshot.value as Map<dynamic, dynamic>;
        for (var key in children.keys) {
          if (children[key]['id'] == widget.movie.id) {
            await dbRef.child(key).remove();
            break;
          }
        }
        setState(() {
          isInWatchlist = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Removed from watchlist!')));
      }
    }
  }

  // Function to fetch cast details
  void fetchCastDetails() async {
    final castMembers =
        await ApiService().fetchCast(widget.movie.id, widget.movie.isTV);
    setState(() {
      cast = castMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with movie title
        title: Text(widget.movie.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0, // Removes the shadow
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Movie image
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.network(
                widget.movie.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            // Movie details
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Overview section
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.movie.overview,
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    // Release date section
                    Text(
                      'Release Date: ${widget.movie.releaseDate ?? 'Unknown'}',
                      style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    // Rating section
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.yellow[700], size: 20),
                        SizedBox(width: 4),
                        Text(
                          '${widget.movie.rating?.toStringAsFixed(1) ?? 'N/A'}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Cast section
                    Text(
                      'Cast',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // List of cast members
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        itemBuilder: (context, index) {
                          final castMember = cast[index];
                          return Card(
                            color: Colors.grey[850],
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        castMember.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    castMember.name,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    castMember.character,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 5,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating action button for watchlist functionality
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isInWatchlist) {
            removeFromWatchlist();
          } else {
            addToWatchlist();
          }
        },
        backgroundColor: isInWatchlist ? Colors.red : Colors.green,
        child: Icon(isInWatchlist ? Icons.remove : Icons.add),
      ),
    );
  }
}
