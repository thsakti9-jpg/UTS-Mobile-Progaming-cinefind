import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/tmdb_config.dart';
import '../models/movie.dart';

class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  Map<String, String> get _headers => {'Authorization': 'Bearer ${TmdbConfig.readAccessToken}', 'accept': 'application/json'};

  Future<Map<String, dynamic>> _getJson(String path, {Map<String, String>? query}) async {
    const token = TmdbConfig.readAccessToken;
    if (token.isEmpty || token.contains('PASTE_YOUR')) throw Exception('Token TMDB belum diisi. Isi lib/config/tmdb_config.dart terlebih dahulu.');
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: {'language': 'en-US', ...?query});
    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));
    if (response.statusCode == 401) throw Exception('Token tidak valid. Periksa kembali kredensial TMDB.');
    if (response.statusCode == 429) throw Exception('Permintaan terlalu banyak. Coba lagi sebentar.');
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('Server TMDB gagal (${response.statusCode}).');
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('Format respons API tidak sesuai.');
    return decoded;
  }

  Future<List<Movie>> getPopularMovies() async => _parseMovies(await _getJson('/movie/popular'));
  Future<List<Movie>> getNowPlayingMovies() async => _parseMovies(await _getJson('/movie/now_playing'));
  Future<List<Movie>> searchMovies(String query) async => _parseMovies(await _getJson('/search/movie', query: {'query': query, 'include_adult': 'false', 'page': '1'}));
  Future<Movie> getMovieDetails(int id) async => Movie.fromJson(await _getJson('/movie/$id'));
  List<Movie> _parseMovies(Map<String, dynamic> data) => (data['results'] as List? ?? []).whereType<Map<String, dynamic>>().map(Movie.fromJson).toList();
}
