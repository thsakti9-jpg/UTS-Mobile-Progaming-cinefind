import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Memuat film...'});
  final String label;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: Color(0xFFE50914)), const SizedBox(height: 16), Text(label, style: const TextStyle(color: Colors.white70))])));
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.white54), const SizedBox(height: 12), const Text('Gagal memuat data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)), const SizedBox(height: 16), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Coba Lagi'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE50914)))])));
}
