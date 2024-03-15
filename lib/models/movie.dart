class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final double? rating;
  final String? releaseDate;
  final bool isTV;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    this.rating,
    this.releaseDate,
    this.isTV = false,
  });

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500/';

  String get imageUrl {
    return posterPath != null ? '$_imageBaseUrl$posterPath' : 'path/to/fallback/image.jpg';
  }

  factory Movie.fromJson(Map<String, dynamic> json, {bool isTV = false}) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown Title',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? '',
      rating: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'],
      isTV: isTV,
    );
  }
  
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
