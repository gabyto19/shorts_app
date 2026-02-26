import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LIKES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LikesNotifier extends StateNotifier<Set<String>> {
  final FirestoreService _firestore;
  final Map<String, int> _likeCounts = {};

  LikesNotifier(this._firestore) : super({}) {
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    try {
      final likes = await _firestore.getLikes();
      if (mounted) state = likes;
    } catch (_) {}
  }

  void initCount(String lessonId, int count) {
    _likeCounts.putIfAbsent(lessonId, () => count);
  }

  bool isLiked(String lessonId) => state.contains(lessonId);

  int getCount(String lessonId) => _likeCounts[lessonId] ?? 0;

  void toggle(String lessonId) {
    HapticFeedback.lightImpact();

    // Optimistic update (instant UI)
    if (state.contains(lessonId)) {
      state = {...state}..remove(lessonId);
      _likeCounts[lessonId] = (_likeCounts[lessonId] ?? 1) - 1;
    } else {
      state = {...state, lessonId};
      _likeCounts[lessonId] = (_likeCounts[lessonId] ?? 0) + 1;
    }

    // Persist to Firestore (async, fire-and-forget)
    _firestore.toggleLike(lessonId);
  }
}

final likesProvider = StateNotifierProvider<LikesNotifier, Set<String>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return LikesNotifier(firestore);
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SAVED / BOOKMARKS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SavedNotifier extends StateNotifier<Set<String>> {
  final FirestoreService _firestore;

  SavedNotifier(this._firestore) : super({}) {
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    try {
      final saved = await _firestore.getSaved();
      if (mounted) state = saved;
    } catch (_) {}
  }

  bool isSaved(String lessonId) => state.contains(lessonId);

  void toggle(String lessonId) {
    HapticFeedback.mediumImpact();

    // Optimistic update
    if (state.contains(lessonId)) {
      state = {...state}..remove(lessonId);
    } else {
      state = {...state, lessonId};
    }

    // Persist to Firestore
    _firestore.toggleSave(lessonId);
  }
}

final savedProvider = StateNotifierProvider<SavedNotifier, Set<String>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return SavedNotifier(firestore);
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  FOLLOWS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FollowsNotifier extends StateNotifier<Set<String>> {
  final FirestoreService _firestore;

  FollowsNotifier(this._firestore) : super({}) {
    _loadFromCloud();
  }

  Future<void> _loadFromCloud() async {
    try {
      final follows = await _firestore.getFollows();
      if (mounted) state = follows;
    } catch (_) {}
  }

  bool isFollowing(String creatorName) => state.contains(creatorName);

  void toggle(String creatorName) {
    HapticFeedback.lightImpact();

    // Optimistic update
    if (state.contains(creatorName)) {
      state = {...state}..remove(creatorName);
    } else {
      state = {...state, creatorName};
    }

    // Persist to Firestore
    _firestore.toggleFollow(creatorName);
  }
}

final followsProvider = StateNotifierProvider<FollowsNotifier, Set<String>>((ref) {
  final firestore = ref.read(firestoreServiceProvider);
  return FollowsNotifier(firestore);
});
