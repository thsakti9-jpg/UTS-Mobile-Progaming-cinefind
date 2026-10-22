# CineFind — Flutter UTS
Nama : Theo Septian Nur M.S. 
Nim :240605110092 
kelas : Mobile Progaming B


Aplikasi penjelajah film dengan Flutter/Dart dan TMDB API.

## Fitur
- Home dengan film populer dan film yang sedang tayang
- Pencarian film berdasarkan judul
- Halaman detail film
- Loading, success, dan error state memakai FutureBuilder
- Retry saat request gagal
- Tema gelap sinematik

## Setup
1. Buat project Flutter baru bernama `cinefind`.
2. Salin folder `lib/` dan `pubspec.yaml` dari paket ini ke project.
3. Salin `lib/config/tmdb_config.example.dart` menjadi `lib/config/tmdb_config.dart`.
4. Isi `readAccessToken` dengan TMDB API Read Access Token milikmu.
5. Jalankan `flutter pub get`, lalu `flutter run`.
6. Di `android/app/src/main/AndroidManifest.xml`, tambahkan `<uses-permission android:name="android.permission.INTERNET"/>` di dalam `<manifest>` dan sebelum `<application>`.

## Keamanan dan atribusi
Jangan commit `lib/config/tmdb_config.dart`; file ini sudah masuk `.gitignore`. Token yang ditanam di aplikasi client tetap dapat diekstrak, jadi gunakan backend/proxy untuk aplikasi produksi. Tambahkan logo TMDB resmi dan atribusi sesuai ketentuan TMDB.

This product uses the TMDB API but is not endorsed or certified by TMDB.
Dokumentasi: https://developer.themoviedb.org/docs/getting-started
