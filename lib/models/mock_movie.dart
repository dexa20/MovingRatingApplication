import 'package:DM_Flix/models/movie.dart';

class MockMovie extends Movie {
  MockMovie({
    int id = 0,
    String title = 'Mock Movie',
    String? posterPath,
    String overview = 'Mock Overview',
    double? rating,
    String? releaseDate,
    bool isTV = false,
  }) : super(
          id: id,
          title: title,
          posterPath: posterPath,
          overview: overview,
          rating: rating,
          releaseDate: releaseDate,
          isTV: isTV,
        );
}
