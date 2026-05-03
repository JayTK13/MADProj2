import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //
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

  // This method allows a user to join an existing playlist by adding their user ID to the playlist's members array in Firestore.
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

    // This method adds a new song to the specified playlist in Firestore, including details such as title, artist, and the user who added it.
    await _db.collection('playlists').doc(playlistId).collection('songs').add({
      'title': title,
      'artist': artist,
      'votes': 0,
      'voters': [],
      'addedBy': user.uid,
      'createdAt': Timestamp.now(),
    });
  }

  // This method allows a user to vote for a song in a playlist.
  //It checks if the user has already voted for the song and, if not,
  //increments the vote count and adds the user's ID to the list of voters.
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
    // The transaction ensures that the vote count is updated automatically
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

  // This method retrieves the top 3 songs from a playlist based on the number of votes.
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

  //  This method allows a user to send a message in the context of a playlist.
  Future<void> sendMessage({
    required String playlistId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await _db.collection('users').doc(user.uid).get();

    final username = userDoc.data()?['username'] ?? "Unknown";

    await _db
        .collection('playlists')
        .doc(playlistId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': user.uid,
          'username': username,
          'timestamp': Timestamp.now(),
        });
  }

  // This method retrieves the messages for a given playlist, ordered by timestamp.
  Stream<QuerySnapshot> getMessages(String playlistId) {
    return _db
        .collection('playlists')
        .doc(playlistId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
