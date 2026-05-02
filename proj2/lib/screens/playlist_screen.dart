import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Playlist Room")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: db.collection('playlists').doc(playlistId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Playlist not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name'] ?? 'Unnamed Playlist';
          final String hostId = data['hostId'] ?? '';
          final List members = data['members'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text("Host: $hostId"),
                Text("Members: ${members.length}"),

                const SizedBox(height: 20),

                const Divider(),

                const Text(
                  "Songs will appear here",
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Voting + queue system coming next...",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Members",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(members[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
