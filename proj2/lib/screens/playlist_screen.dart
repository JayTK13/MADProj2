import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    final titleController = TextEditingController();
    final artistController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Playlist Room")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Song Title"),
                ),
                TextField(
                  controller: artistController,
                  decoration: const InputDecoration(labelText: "Artist"),
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        artistController.text.isEmpty)
                      return;

                    await service.addSong(
                      playlistId: playlistId,
                      title: titleController.text,
                      artist: artistController.text,
                    );

                    titleController.clear();
                    artistController.clear();
                  },
                  child: const Text("Add Song"),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getSongs(playlistId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final songs = snapshot.data!.docs;

                if (songs.isEmpty) {
                  return const Center(child: Text("No song added yet"));
                }

                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];

                    return ListTile(
                      leading: const Icon(Icons.music_note),

                      title: Text(song['title']),
                      subtitle: Text(song['artist']),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("🔥 ${song['votes'] ?? 0}"),

                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () {
                              service.voteSong(
                                playlistId: playlistId,
                                songId: song.id,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
