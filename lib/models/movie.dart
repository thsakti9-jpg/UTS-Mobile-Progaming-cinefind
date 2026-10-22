class Movie {
  final int id;
  final String title, overview, posterPath, backdropPath, releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final List<String> genres;
  final int? runtime;

  const Movie({required this.id, required this.title, required this.overview, required this.posterPath, required this.backdropPath, required this.releaseDate, required this.voteAverage, required this.genreIds, this.genres = const [], this.runtime});

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'];
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['original_title'] ?? 'Untitled').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      backdropPath: (json['backdrop_path'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? '').toString(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreIds: (json['genre_ids'] as List? ?? []).whereType<num>().map((e) => e.toInt()).toList(),
      genres: rawGenres is List ? rawGenres.whereType<Map>().map((e) => (e['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList() : const [],
      runtime: (json['runtime'] as num?)?.toInt(),
    );
  }

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'TBA';
  String get posterUrl => posterPath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w500$posterPath';
  String get backdropUrl => backdropPath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w1280$backdropPath';
}
