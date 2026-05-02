import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createPlaylist({required String name}) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('playlists').add({
      'name': name,
      'hostId': user!.uid,
      'createdAt': Timestamp.now(),
      'currentSongId': '',
      'isActive': true,
      'members': [user.uid],
    });
  }

  Stream<QuerySnapshot> getPlaylists() {
    return _db.collection('playlists').snapshots();
  }
}
