import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/models/movie.dart'; 
import '/services/api_service.dart'; 
import '../main_screens/detail_screen.dart'; 

class TrendingSlider extends StatelessWidget {
  TrendingSlider({Key? key}) : super(key: key);

  final ApiService _movieApi = ApiService(); 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _movieApi.fetchTrendingMovies(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
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
                      builder: (context) => DetailScreen(movie: snapshot.data![itemIndex]), 
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    snapshot.data![itemIndex].imageUrl, 
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
          return const Text('No trending movies found');
        }
      },
    );
  }
}
