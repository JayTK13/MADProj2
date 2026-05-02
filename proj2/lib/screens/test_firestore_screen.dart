import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestoreScreen extends StatelessWidget {
  const TestFirestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text("Firestore Test")),
      body: StreamBuilder(
        stream: db.collection('playlists').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView(
            children: docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['hostId']),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          db.collection('playlists').add({
            'name': 'Test Playlist',
            'hostId': 'user1',
            'createdAt': Timestamp.now(),
            'currentSongId': '',
            'isActive': true,
            'members': ['user1'],
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
