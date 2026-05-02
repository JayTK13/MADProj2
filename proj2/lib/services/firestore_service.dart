import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> createPlaylist({required String name}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final docRef = await _db.collection('playlists').add({
      'name': name,
      'hostId': user.uid,
      'createdAt': Timestamp.now(),
      'currentSongId': '',
      'isActive': true,
      'members': [user.uid],
    });

    return docRef.id;
  }

  Future<void> joinPlaylist(String playlistId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('playlists').doc(playlistId).update({
      'members': FieldValue.arrayUnion([user.uid]),
    });
  }

  Stream<QuerySnapshot> getPlaylists() {
    return _db.collection('playlists').snapshots();
  }

  Stream<DocumentSnapshot> getPlaylist(String playlistId) {
    return _db.collection('playlists').doc(playlistId).snapshots();
  }
}
