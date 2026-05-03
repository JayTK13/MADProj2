import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firestore_service.dart';
import 'song_search_screen.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final messageController = TextEditingController();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? "New Notification"),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlist Room"),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongSearchScreen(playlistId: playlistId),
                ),
              );
            },
          ),
        ],
      ),

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

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top Recommended Songs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: service.getTopSongs(playlistId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final songs = snapshot.data!;

                    if (songs.isEmpty) {
                      return const Text("No recommendations yet");
                    }

                    return Column(
                      children: songs.map((song) {
                        return ListTile(
                          leading: const Icon(Icons.star, color: Colors.orange),
                          title: Text(song['title']),
                          subtitle: Text(song['artist']),
                          trailing: Text("${song['votes']}"),
                        );
                      }).toList(),
                    );
                  },
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
                          Text("${song['votes'] ?? 0}"),
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

          Container(
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                const Text(
                  "Chat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: service.getMessages(playlistId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];

                          return ListTile(
                            dense: true,
                            title: Text(msg['text']),
                            subtitle: Text("User: ${msg['senderId']}"),
                          );
                        },
                      );
                    },
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (messageController.text.isEmpty) return;

                        await service.sendMessage(
                          playlistId: playlistId,
                          text: messageController.text,
                        );

                        messageController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
