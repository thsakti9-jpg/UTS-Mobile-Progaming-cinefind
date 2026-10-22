import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 146,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: movie.posterUrl.isEmpty
                        ? _placeholder()
                        : Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: cineSurface,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cineRed,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: cineGold, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.66),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onFavoriteTap,
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 17,
                              color: isFavorite ? cineRed : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.25, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(movie.year, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF202027),
        alignment: Alignment.center,
        child: const Icon(Icons.movie_outlined, size: 38, color: Colors.white30),
      );
}
