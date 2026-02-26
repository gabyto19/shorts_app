import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central service for all Firestore operations.
/// Handles user profiles, likes, saves, and follows.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Current user reference ───
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference? get _userDoc =>
      _uid != null ? _db.collection('users').doc(_uid) : null;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  USER PROFILE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Create user profile document on signup
  Future<void> createUserProfile({
    required String uid,
    required String displayName,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'displayName': displayName,
      'email': email,
      'bio': '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userDoc == null) return null;
    final doc = await _userDoc!.get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// Update user profile fields (creates doc if it doesn't exist)
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set(data, SetOptions(merge: true));
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  LIKES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Toggle like on a lesson
  Future<void> toggleLike(String lessonId) async {
    if (_userDoc == null) return;
    final likeRef = _userDoc!.collection('likes').doc(lessonId);
    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Get all liked lesson IDs
  Future<Set<String>> getLikes() async {
    if (_userDoc == null) return {};
    final snapshot = await _userDoc!.collection('likes').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Stream of liked lesson IDs (real-time)
  Stream<Set<String>> likesStream() {
    if (_userDoc == null) return Stream.value({});
    return _userDoc!.collection('likes').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SAVED / BOOKMARKS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Toggle save on a lesson
  Future<void> toggleSave(String lessonId) async {
    if (_userDoc == null) return;
    final saveRef = _userDoc!.collection('saved').doc(lessonId);
    final doc = await saveRef.get();

    if (doc.exists) {
      await saveRef.delete();
    } else {
      await saveRef.set({'savedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Get all saved lesson IDs
  Future<Set<String>> getSaved() async {
    if (_userDoc == null) return {};
    final snapshot = await _userDoc!.collection('saved').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Stream of saved lesson IDs (real-time)
  Stream<Set<String>> savedStream() {
    if (_userDoc == null) return Stream.value({});
    return _userDoc!.collection('saved').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  FOLLOWS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Toggle follow on a creator
  Future<void> toggleFollow(String creatorName) async {
    if (_userDoc == null) return;
    final followRef = _userDoc!.collection('follows').doc(creatorName);
    final doc = await followRef.get();

    if (doc.exists) {
      await followRef.delete();
    } else {
      await followRef.set({'followedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Get all followed creator names
  Future<Set<String>> getFollows() async {
    if (_userDoc == null) return {};
    final snapshot = await _userDoc!.collection('follows').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Stream of followed creators (real-time)
  Stream<Set<String>> followsStream() {
    if (_userDoc == null) return Stream.value({});
    return _userDoc!.collection('follows').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  USER STATS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get user interaction counts for profile
  Future<Map<String, int>> getUserStats() async {
    if (_userDoc == null) return {'likes': 0, 'saved': 0, 'follows': 0};

    final results = await Future.wait([
      _userDoc!.collection('likes').count().get(),
      _userDoc!.collection('saved').count().get(),
      _userDoc!.collection('follows').count().get(),
    ]);

    return {
      'likes': results[0].count ?? 0,
      'saved': results[1].count ?? 0,
      'follows': results[2].count ?? 0,
    };
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  COMMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Add a comment to a lesson
  Future<void> addComment({
    required String lessonId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('comments').doc(lessonId).collection('messages').add({
      'uid': user.uid,
      'userName': user.displayName ?? 'User',
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream comments for a lesson (newest first)
  Stream<List<Map<String, dynamic>>> commentsStream(String lessonId) {
    return _db
        .collection('comments')
        .doc(lessonId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Get comment count for a lesson
  Future<int> getCommentCount(String lessonId) async {
    final result = await _db
        .collection('comments')
        .doc(lessonId)
        .collection('messages')
        .count()
        .get();
    return result.count ?? 0;
  }

  /// Delete a comment (only by the author)
  Future<void> deleteComment(String lessonId, String commentId) async {
    await _db
        .collection('comments')
        .doc(lessonId)
        .collection('messages')
        .doc(commentId)
        .delete();
  }
}
