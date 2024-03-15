// Class representing a cast member in a movie or TV show
class CastMember {
  // Unique identifier for the cast member
  final int id;
  // Name of the cast member
  final String name;
  // Character played by the cast member
  final String character;
  // Path to the profile image of the cast member (optional)
  final String? profilePath;

  // Constructor for creating a CastMember instance
  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  // Base URL for retrieving profile images
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500/';

  // Get the full URL for the profile image of the cast member
  String get imageUrl => profilePath != null ? '$_imageBaseUrl$profilePath' : 'path/to/default/fallback/image.jpg';

  // Factory method to create a CastMember instance from JSON data
  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['cast_id'] ?? json['id'], // Adjust based on actual JSON structure
      name: json['name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }
}
