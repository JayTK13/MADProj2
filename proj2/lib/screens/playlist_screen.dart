import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? "New Notification"),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Playlist Room")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room ID: $playlistId",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: playlistId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Room ID copied to clipboard"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: "Song Title",
                            ),
                          ),
                          TextField(
                            controller: artistController,
                            decoration: const InputDecoration(
                              labelText: "Artist",
                            ),
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

                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text("Search from Spotify"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SongSearchScreen(playlistId: playlistId),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.music_note),
                            label: const Text("View Songs & Vote"),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    SongListBottomSheet(playlistId: playlistId),
                              );
                            },
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                    leading: const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                    ),
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
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("Open Chat"),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ChatBottomSheet(playlistId: playlistId),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongListBottomSheet extends StatelessWidget {
  final String playlistId;

  const SongListBottomSheet({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Container(
      height: 500,
      padding: const EdgeInsets.all(10),
      child: StreamBuilder<QuerySnapshot>(
        stream: service.getSongs(playlistId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!.docs;

          if (songs.isEmpty) {
            return const Center(child: Text("No songs yet"));
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
    );
  }
}

class ChatBottomSheet extends StatefulWidget {
  final String playlistId;

  const ChatBottomSheet({super.key, required this.playlistId});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final service = FirestoreService();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text("Chat", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.getMessages(widget.playlistId),
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
                      playlistId: widget.playlistId,
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
    );
  }
}
