import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../services/firestore_service.dart';

// This screen allows users to search for songs using the Spotify API and add them to a playlist.
class SongSearchScreen extends StatefulWidget {
  final String playlistId;

  const SongSearchScreen({super.key, required this.playlistId});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

// The _SongSearchScreenState class manages the state of the SongSearchScreen,
//including handling the search functionality and displaying the search results.
class _SongSearchScreenState extends State<SongSearchScreen> {
  final spotify = SpotifyService();
  final firestore = FirestoreService();

  final controller = TextEditingController();
  List<Map<String, String>> results = [];

  void search() async {
    final data = await spotify.searchSongs(controller.text);
    setState(() {
      results = data;
    });
  }

  // The build method constructs the UI for the song search screen,
  //allowing users to search for songs and add them to a playlist.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Songs")),

      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Search song"),
          ),

          ElevatedButton(onPressed: search, child: const Text("Search")),

          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final song = results[index];

                return ListTile(
                  title: Text(song["title"]!),
                  subtitle: Text(song["artist"]!),

                  onTap: () async {
                    await firestore.addSong(
                      playlistId: widget.playlistId,
                      title: song["title"]!,
                      artist: song["artist"]!,
                    );

                    Navigator.pop(
                      context,
                    ); // Close the search screen after adding the song to the playlist
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
