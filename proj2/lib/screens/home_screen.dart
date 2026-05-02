import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Vibzcheck Home")),
      body: const Center(child: Text("Create or Join a Playlist")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await service.createPlaylist(name: "New Playlist");

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Playlist Created")));

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlaylistScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
