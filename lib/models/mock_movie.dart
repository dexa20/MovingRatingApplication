import 'package:DM_Flix/models/movie.dart';

// Class representing a mock movie for testing purposes
class MockMovie extends Movie {
  // Constructor for creating a mock movie instance
  MockMovie({
    int id = 0, // Unique identifier for the movie
    String title = 'Mock Movie', // Title of the movie
    String? posterPath, // Path to the poster image of the movie
    String overview = 'Mock Overview', // Overview of the movie
    double? rating, // Rating of the movie
    String? releaseDate, // Release date of the movie
    bool isTV = false, // Flag indicating if the movie is a TV show
  }) : super(
          // Call the constructor of the superclass (Movie)
          id: id,
          title: title,
          posterPath: posterPath,
          overview: overview,
          rating: rating,
          releaseDate: releaseDate,
          isTV: isTV,
        );
}
