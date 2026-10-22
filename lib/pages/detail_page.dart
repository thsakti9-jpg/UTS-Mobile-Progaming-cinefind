import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/loading_view.dart';

class DetailPage extends StatefulWidget {
  final int movieId;
  final Movie fallbackMovie;

  const DetailPage({super.key, required this.movieId, required this.fallbackMovie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TmdbService _service = TmdbService();
  late Future<Movie> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMovieDetails(widget.movieId);
  }

  void _retry() => setState(() => _future = _service.getMovieDetails(widget.movieId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(label: 'Loading the movie story...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _retry,
            );
          }
          return _content(snapshot.data ?? widget.fallbackMovie);
        },
      ),
    );
  }

  Widget _content(Movie movie) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          backgroundColor: cineBg,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (movie.backdropUrl.isNotEmpty)
                  Image.network(movie.backdropUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: cineSurface))
                else
                  Container(color: cineSurface),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xFF09090D)],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 23,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: cineRed, borderRadius: BorderRadius.circular(8)),
                    child: const Text('MOVIE DETAILS', style: TextStyle(fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 5, 22, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: const TextStyle(fontSize: 32, height: 1.04, letterSpacing: -0.8, fontWeight: FontWeight.w900)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 9,
                  children: [
                    _infoPill(Icons.star_rounded, movie.voteAverage.toStringAsFixed(1), accent: cineGold),
                    _infoPill(Icons.calendar_month_rounded, movie.year),
                    if (movie.runtime != null && movie.runtime! > 0) _infoPill(Icons.schedule_rounded, '${movie.runtime} min'),
                  ],
                ),
                if (movie.genres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres.map((genre) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF181820), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF30303A))),
                      child: Text(genre, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 29),
                const Text('THE STORY', style: TextStyle(color: Color(0xFFFF777F), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text(
                  movie.overview.isEmpty ? 'A synopsis is not available for this movie yet.' : movie.overview,
                  style: const TextStyle(fontSize: 14, height: 1.75, color: Color(0xFFD2D2D8)),
                ),
                const SizedBox(height: 28),
                const Text('MOVIE INFO', style: TextStyle(color: Color(0xFFFF777F), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 13),
                _detailRow('Release date', movie.releaseDate.isEmpty ? 'Not available' : movie.releaseDate),
                _detailRow('User rating', '${movie.voteAverage.toStringAsFixed(1)} / 10'),
                _detailRow('Movie ID', '${movie.id}'),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF14141A), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF292930))),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.white54),
                    SizedBox(width: 10),
                    Expanded(child: Text('This product uses the TMDB API but is not endorsed or certified by TMDB.', style: TextStyle(fontSize: 11, height: 1.5, color: Colors.white54))),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoPill(IconData icon, String text, {Color accent = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF17171D), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: accent, size: 16),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent)),
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 118, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4))),
      ]),
    );
  }
}
