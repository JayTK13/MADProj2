import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'join_playlist_screen.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Vibzcheck Home"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Playlist Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final playlistId = await service.createPlaylist(
                  name: nameController.text,
                );

                nameController.clear();

                if (playlistId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to create playlist")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Playlist Created")),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistScreen(playlistId: playlistId),
                  ),
                );
              },
              child: const Text("Create Playlist"),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinPlaylistScreen()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text("Join Playlist"),
            ),
          ],
        ),
      ),
    );
  }
}
