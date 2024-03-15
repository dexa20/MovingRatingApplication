// Class representing a movie or TV show
class Movie {
  // Unique identifier for the movie or TV show
  final int id;
  // Title of the movie or TV show
  final String title;
  // Path to the poster image of the movie or TV show (optional)
  final String? posterPath;
  // Overview or description of the movie or TV show
  final String overview;
  // Rating of the movie or TV show (optional)
  final double? rating;
  // Release date of the movie or TV show (optional)
  final String? releaseDate;
  // Flag indicating if the item is a TV show
  final bool isTV;

  // Constructor for creating a Movie instance
  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    this.rating,
    this.releaseDate,
    this.isTV = false,
  });

  // Base URL for retrieving poster images
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500/';

  // Get the full URL for the poster image of the movie or TV show
  String get imageUrl {
    return posterPath != null ? '$_imageBaseUrl$posterPath' : 'path/to/fallback/image.jpg';
  }

  // Factory method to create a Movie instance from JSON data
  factory Movie.fromJson(Map<String, dynamic> json, {bool isTV = false}) {
    return Movie(
      id: json['id'] as int? ?? 0, // Unique identifier
      title: json['title'] ?? json['name'] ?? 'Unknown Title', // Title
      posterPath: json['poster_path'], // Poster image path
      overview: json['overview'] ?? '', // Overview
      rating: (json['vote_average'] as num?)?.toDouble(), // Rating
      releaseDate: json['release_date'] ?? json['first_air_date'], // Release date
      isTV: isTV, // Flag indicating if it's a TV show
    );
  }
  
  // Convert Movie instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': rating,
      'release_date': releaseDate,
      'isTV': isTV,
    };
  }
}
