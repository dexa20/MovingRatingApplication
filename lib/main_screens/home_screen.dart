import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/api_service.dart';
import '/models/movie.dart';
import '/widgets/movie_card.dart';
import '/widgets/trending_slider.dart';
import '/authentication_screens/login_screen.dart';
import 'detail_screen.dart';
import 'movie_screen.dart';
import 'tv_show_screen.dart';
import 'watchlist_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final ApiService _movieService = ApiService();

  HomeScreen({Key? key}) : super(key: key);

  Stream<String> fetchUserProfilePictureUrlStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists && snapshot.data()!.containsKey('profilePicture')) {
              return snapshot.data()!['profilePicture'];
            }
            return '';
          });
    }
    return Stream.value(''); // Return an empty stream if user is null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DM Flix',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
          StreamBuilder<String>(
            stream: fetchUserProfilePictureUrlStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: EdgeInsets.all(10),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
                      radius: 16,
                    ),
                  ),
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[900],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No email found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.movie, 'Movies', () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MovieScreen()))),
              _drawerItem(Icons.tv, 'TV Shows', () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TVShowScreen()))),
              _drawerItem(Icons.watch_later, 'Watchlist', () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => WatchlistScreen()))),
              Divider(color: Colors.grey[800]),
              _drawerItem(Icons.logout, 'Logout', () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('rememberMe', false);
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false);
              }),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionTitle('Trending Movies'),
              TrendingSlider(),
              _buildSectionTitle('What\'s on at the cinema?'),
              _buildMovieSection(_movieService.fetchCinemaMovies()),
              _buildSectionTitle('What\'s on TV tonight?'),
              _buildMovieSection(_movieService.fetchTVAiringToday()),
              _buildSectionTitle('What are the best movies this year?'),
              _buildMovieSection(_movieService.fetchBestMoviesOfYear()),
              _buildSectionTitle('Highest Grossing Movies of All Time'),
              _buildMovieSection(_movieService.fetchHighestGrossingMovies()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildMovieSection(Future<List<Movie>> moviesFuture) {
    return FutureBuilder<List<Movie>>(
      future: moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
        } else if (snapshot.hasData) {
          return Container(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Movie movie = snapshot.data![index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailScreen(movie: movie))),
                  child: MovieCard(movie: movie),
                );
              },
            ),
          );
        } else {
          return const Text('No movies found', style: TextStyle(color: Colors.white));
        }
      },
    );
  }
}
