import 'package:flutter/material.dart';
import '/models/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    checkIfInWatchlist();
  }

  void checkIfInWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref('watchlist/${user.uid}');
      final snapshot = await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        setState(() {
          isInWatchlist = true;
        });
      } else {
        setState(() {
          isInWatchlist = false;
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
        isInWatchlist = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to watchlist!')));
    }
  }

  void removeFromWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref('watchlist/${user.uid}');
      final snapshot = await dbRef.orderByChild('id').equalTo(widget.movie.id).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> children = snapshot.value as Map<dynamic, dynamic>;
        children.forEach((key, value) async {
          if (value['id'] == widget.movie.id) {
            await dbRef.child(key).remove();
            setState(() {
              isInWatchlist = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from watchlist!')));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(
              widget.movie.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
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
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isInWatchlist) {
            removeFromWatchlist();
          } else {
            addToWatchlist();
          }
        },
        backgroundColor: Colors.green,
        child: Icon(isInWatchlist ? Icons.remove : Icons.add),
      ),
    );
  }
}
