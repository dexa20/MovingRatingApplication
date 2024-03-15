import 'package:flutter/material.dart'; // Importing Flutter material library
import 'package:carousel_slider/carousel_slider.dart'; // Importing Carousel Slider library
import '/models/movie.dart'; // Importing movie model
import '/services/api_service.dart'; // Importing API service for fetching trending movies
import '../main_screens/detail_screen.dart'; // Importing detail screen for displaying movie details

class TrendingSlider extends StatelessWidget {
  TrendingSlider({Key? key}) : super(key: key);

  final ApiService _movieApi = ApiService(); // Instance of ApiService for fetching trending movies

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>( // Asynchronous operation to build UI based on future result
      future: _movieApi.fetchTrendingMovies(), // Fetching trending movies
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // When data is loading
          return const Center(child: CircularProgressIndicator()); // Displaying loading indicator
        } else if (snapshot.hasError) { // If an error occurred
          return Text('Error: ${snapshot.error}'); // Displaying error message
        } else if (snapshot.hasData) { // If data is available
          return SizedBox(
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: snapshot.data!.length,
              options: CarouselOptions(
                height: 300,
                autoPlay: true,
                viewportFraction: 0.55,
                enlargeCenterPage: true,
                pageSnapping: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(seconds: 1),
              ),
              itemBuilder: (context, itemIndex, pageViewIndex) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: snapshot.data![itemIndex]), // Navigating to detail screen with selected movie
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    snapshot.data![itemIndex].imageUrl, // Displaying movie image
                    height: 300,
                    width: 200,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Text('No trending movies found'); // If no data is available, display message
        }
      },
    );
  }
}
