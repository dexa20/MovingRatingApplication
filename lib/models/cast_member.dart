// cast_member.dart
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500/';

  String get imageUrl => profilePath != null ? '$_imageBaseUrl$profilePath' : 'path/to/default/fallback/image.jpg';

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['cast_id'] ?? json['id'], // Adjust based on actual JSON structure
      name: json['name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }
}
