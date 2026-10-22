import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_card.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  final Map<int, Movie> favorites;
  final ValueChanged<Movie> onToggleFavorite;

  const SearchPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TmdbService _service = TmdbService();
  final TextEditingController _controller = TextEditingController();
  Future<List<Movie>>? _future;
  String _query = '';

  void _search(String value) {
    final query = value.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = query;
      _future = query.isEmpty ? null : _service.searchMovies(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(movieId: movie.id, fallbackMovie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 24, 21, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THE MOVIE INDEX', style: TextStyle(color: Color(0xFFFF777F), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Find your\nnext favorite.', style: TextStyle(fontSize: 34, height: 1.03, letterSpacing: -1.1, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  decoration: InputDecoration(
                    hintText: 'Search a movie title...',
                    prefixIcon: const Icon(Icons.search_rounded, color: cineRed),
                    suffixIcon: IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _query = '';
                          _future = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Dune', 'Batman', 'Spider-Man', 'Inside Out'].map((title) {
                    return ActionChip(
                      label: Text(title),
                      onPressed: () {
                        _controller.text = title;
                        _search(title);
                      },
                      side: const BorderSide(color: Color(0xFF303039)),
                      backgroundColor: const Color(0xFF15151C),
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.white70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        if (_future == null)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(38, 0, 38, 40),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.local_movies_outlined, size: 60, color: Color(0xFF383840)),
                  SizedBox(height: 15),
                  Text('A whole world of cinema.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 7),
                  Text('Search by title to explore posters, ratings and movie details.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.5)),
                ]),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: FutureBuilder<List<Movie>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 250, child: LoadingView(label: 'Searching the collection...'));
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: ErrorView(
                      message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                      onRetry: () => _search(_query),
                    ),
                  );
                }
                final movies = snapshot.data ?? [];
                if (movies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.white30),
                      SizedBox(height: 12),
                      Text('No movies found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      SizedBox(height: 5),
                      Text('Try another title.', style: TextStyle(color: Colors.white54)),
                    ]),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 14),
                        child: Text('${movies.length} RESULTS FOR “${_query.toUpperCase()}”', style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.51,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (_, index) {
                          final movie = movies[index];
                          return MovieCard(
                            movie: movie,
                            width: double.infinity,
                            isFavorite: widget.favorites.containsKey(movie.id),
                            onFavoriteTap: () => widget.onToggleFavorite(movie),
                            onTap: () => _openDetail(movie),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
