import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'playlist_screen.dart';

class JoinPlaylistScreen extends StatefulWidget {
  const JoinPlaylistScreen({super.key});

  @override
  State<JoinPlaylistScreen> createState() => _JoinPlaylistScreenState();
}

// This screen allows users to join an existing playlist by entering its ID.
//It interacts with the FirestoreService to join the playlist and then navigates to the PlaylistScreen if successful.
class _JoinPlaylistScreenState extends State<JoinPlaylistScreen> {
  final controller = TextEditingController();
  final service = FirestoreService();

  void join() async {
    await service.joinPlaylist(controller.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistScreen(playlistId: controller.text),
      ),
    );
  }

  // The build method constructs the UI for the join playlist screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Playlist")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Enter Playlist ID"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: join, child: const Text("Join")),
          ],
        ),
      ),
    );
  }
}
