import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createPlaylist({
    required String name,
    required String hostId,
  }) async {
    await _db.collection('playlists').add({
      'name': name,
      'hostId': hostId,
      'createdAt': Timestamp.now(),
      'currentSongId': '',
      'isActive': true,
      'members': [hostId],
    });
  }
}

Stream<QuerySnapshot> getPlaylists() {
  return _db.collection('playlists').snapshots();
}
