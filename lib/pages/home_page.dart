import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_card.dart';
import 'detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TmdbService _service = TmdbService();
  late Future<List<Movie>> _popularFuture;
  late Future<List<Movie>> _nowPlayingFuture;
  final Map<int, Movie> _favorites = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _popularFuture = _service.getPopularMovies();
    _nowPlayingFuture = _service.getNowPlayingMovies();
  }

  Future<void> _refresh() async {
    setState(_reload);
    try {
      await Future.wait([_popularFuture, _nowPlayingFuture]);
    } catch (_) {
      // FutureBuilder displays the error state.
    }
  }

  void _toggleFavorite(Movie movie) {
    setState(() {
      if (_favorites.containsKey(movie.id)) {
        _favorites.remove(movie.id);
      } else {
        _favorites[movie.id] = movie;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_favorites.containsKey(movie.id)
              ? 'Ditambahkan ke Watchlist'
              : 'Dihapus dari Watchlist'),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(movieId: movie.id, fallbackMovie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeBody(),
      SearchPage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      _watchlistBody(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.travel_explore_outlined), selectedIcon: Icon(Icons.travel_explore_rounded), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.bookmark_border_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Watchlist'),
        ],
      ),
    );
  }

  Widget _homeBody() {
    return RefreshIndicator(
      color: cineRed,
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _searchShortcut()),
          SliverToBoxAdapter(child: _featured()),
          SliverToBoxAdapter(
            child: _movieSection(
              title: 'Trending this week',
              subtitle: 'Cerita yang lagi ramai dibicarakan',
              future: _popularFuture,
            ),
          ),
          SliverToBoxAdapter(
            child: _movieSection(
              title: 'Now showing',
              subtitle: 'Film yang sedang tayang di bioskop',
              future: _nowPlayingFuture,
            ),
          ),
          const SliverToBoxAdapter(child: _AttributionFooter()),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF3442), cineRed]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: cineRed.withValues(alpha: 0.23), blurRadius: 18, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CINEFIND', style: TextStyle(fontSize: 18, letterSpacing: 2.5, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('YOUR NEXT MOVIE OBSESSION', style: TextStyle(fontSize: 9, letterSpacing: 1.1, color: Colors.white38, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: cineSurface, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF282830))),
            child: IconButton(
              tooltip: 'Watchlist',
              onPressed: () => setState(() => _selectedTab = 2),
              icon: const Icon(Icons.bookmark_add_outlined, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchShortcut() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedTab = 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF15151B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF282830)),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.white54, size: 21),
              SizedBox(width: 11),
              Expanded(child: Text('Cari film, aktor, atau judul...', style: TextStyle(color: Colors.white38, fontSize: 13))),
              Icon(Icons.tune_rounded, color: cineRed, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featured() {
    return FutureBuilder<List<Movie>>(
      future: _popularFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Container(
            height: 390,
            margin: const EdgeInsets.fromLTRB(18, 2, 18, 25),
            decoration: BoxDecoration(color: cineSurface, borderRadius: BorderRadius.circular(25)),
            child: const LoadingView(label: 'Menyiapkan pilihan film...'),
          );
        }
        if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
              child: ErrorView(
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => setState(_reload),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final movie = snapshot.data!.first;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 25),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              height: 390,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (movie.backdropUrl.isNotEmpty)
                    Image.network(movie.backdropUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF24242B)))
                  else
                    Container(color: const Color(0xFF24242B)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0x35000000), Color(0xF509090D)],
                        stops: [0, .32, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(color: cineRed, borderRadius: BorderRadius.circular(9)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.bolt_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('SPOTLIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      ]),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _roundButton(
                      icon: _favorites.containsKey(movie.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _favorites.containsKey(movie.id) ? cineRed : Colors.white,
                      onTap: () => _toggleFavorite(movie),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TONIGHT’S PICK', style: TextStyle(fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.w800, color: Color(0xFFFFA4A9))),
                        const SizedBox(height: 9),
                        Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 31, height: 1.02, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 18, color: cineGold),
                          const SizedBox(width: 4),
                          Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(width: 10),
                          const Text('•', style: TextStyle(color: Colors.white38)),
                          const SizedBox(width: 10),
                          Text(movie.year, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 10),
                          const Text('•', style: TextStyle(color: Colors.white38)),
                          const SizedBox(width: 10),
                          const Text('Movie pick', style: TextStyle(color: Colors.white70)),
                        ]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: () => _openDetail(movie),
                            style: FilledButton.styleFrom(backgroundColor: cineRed, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                            label: const Text('Explore movie', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _roundButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.62),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: color, size: 19)),
      ),
    );
  }

  Widget _movieSection({required String title, required String subtitle, required Future<List<Movie>> future}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                ])),
                const Text('SEE ALL', style: TextStyle(color: Color(0xFFFF777F), fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 242, child: LoadingView(label: 'Memuat film...'));
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ErrorView(message: snapshot.error.toString().replaceFirst('Exception: ', ''), onRetry: () => setState(_reload)),
                );
              }
              final movies = snapshot.data ?? [];
              if (movies.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('Belum ada film untuk ditampilkan.'));
              return SizedBox(
                height: 254,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 13),
                  itemBuilder: (_, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      isFavorite: _favorites.containsKey(movie.id),
                      onFavoriteTap: () => _toggleFavorite(movie),
                      onTap: () => _openDetail(movie),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _watchlistBody() {
    final movies = _favorites.values.toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR WATCHLIST', style: TextStyle(color: Color(0xFFFF777F), fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('Saved for later.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
              const SizedBox(height: 6),
              Text('${movies.length} movie${movies.length == 1 ? '' : 's'} saved', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
        ),
        if (movies.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(34),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bookmark_add_outlined, size: 62, color: Color(0xFF45454F)),
                  SizedBox(height: 16),
                  Text('Your list is waiting', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  SizedBox(height: 7),
                  Text('Tap the heart on any movie poster to save it here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.5)),
                ]),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 14, childAspectRatio: 0.51),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    movie: movie,
                    width: double.infinity,
                    isFavorite: true,
                    onFavoriteTap: () => _toggleFavorite(movie),
                    onTap: () => _openDetail(movie),
                  );
                },
                childCount: movies.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _AttributionFooter extends StatelessWidget {
  const _AttributionFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(children: [
        Divider(color: Color(0xFF26262D)),
        SizedBox(height: 13),
        Text('CINEFIND  •  STORIES WORTH YOUR TIME', style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text('This product uses the TMDB API but is not endorsed or certified by TMDB.', style: TextStyle(color: Colors.white30, fontSize: 9, height: 1.5), textAlign: TextAlign.center),
      ]),
    );
  }
}
