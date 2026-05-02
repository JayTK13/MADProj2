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

  Future<void> addSong({
    required String playlistId,
    required String title,
    required String artist,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('playlists').doc(playlistId).collection('songs').add({
      'title': title,
      'artist': artist,
      'votes': 0,
      'voters': [],
      'addedBy': user.uid,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> voteSong({
    required String playlistId,
    required String songId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final songRef = _db
        .collection('playlists')
        .doc(playlistId)
        .collection('songs')
        .doc(songId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(songRef);

      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      final List voters = (data['voters'] ?? []);

      if (voters.contains(user.uid)) {
        return;
      }

      transaction.update(songRef, {
        'votes': (data['votes'] ?? 0) + 1,
        'voters': FieldValue.arrayUnion([user.uid]),
      });
    });
  }

  Stream<QuerySnapshot> getSongs(String playlistId) {
    return _db
        .collection('playlists')
        .doc(playlistId)
        .collection('songs')
        .orderBy('votes', descending: true)
        .snapshots();
  }

  
  Stream<List<QueryDocumentSnapshot>> getTopSongs(String playlistId) {
  return _db
      .collection('playlists')
      .doc(playlistId)
      .collection('songs')
      .orderBy('votes', descending: true)
      .limit(3)
      .snapshots()
      .map((snapshot) => snapshot.docs);
  }
}
