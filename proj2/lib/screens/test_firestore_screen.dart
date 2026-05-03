import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestoreScreen extends StatelessWidget {
  const TestFirestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    // This screen is a testing interface for the Firestore database
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
      // A floating action button is provided to add a test playlist document to the Firestore database when pressed.
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
