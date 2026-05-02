import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Playlists")),
      body: StreamBuilder(
        stream: db.collection('playlists').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final playlists = snapshot.data!.docs;

          return ListView(
            children: playlists.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text("Host: ${doc['hostId']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
