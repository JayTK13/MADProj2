import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'song_search_screen.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_gate.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    final titleController = TextEditingController();
    final artistController = TextEditingController();

    // Listen for incoming FCM messages and show a snackbar notification when a new message is received.
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
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              MyApp.of(context).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout?"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    // Redirects user to login screen after a signout
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthGate()),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display the playlist ID and provide a button to copy it to the clipboard for easy sharing with others.
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

                          // Provide buttons to search for songs from Spotify and to view the list of songs in the playlist along with voting options.
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

                          // Display the top recommended songs based on votes, allowing users to see which songs are most popular in the playlist.
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
            // Provide a button to open the chat interfacce
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

// This widget displays the list of songs in the playlist along with their vote counts and provides a button for users to vote for their favorite songs.
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

// This widget provides a chat interface for users in the playlist, allowing them to send and receive messages in real-time using Firestore as the backend.
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
                      final data = msg.data() as Map<String, dynamic>;

                      // Extract the message text and username from the Firestore document, providing default values if they are not present.
                      final text = data['text'] ?? "";
                      final username = data['username'] ?? "Unknown User";

                      return ListTile(
                        dense: true,
                        title: Text(text),
                        subtitle: Text(username),
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
