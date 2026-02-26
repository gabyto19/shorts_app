import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LIKES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LikesNotifier extends StateNotifier<Set<String>> {
  final Map<String, int> _likeCounts = {};

  LikesNotifier() : super({});

  void initCount(String lessonId, int count) {
    _likeCounts.putIfAbsent(lessonId, () => count);
  }

  bool isLiked(String lessonId) => state.contains(lessonId);

  int getCount(String lessonId) => _likeCounts[lessonId] ?? 0;

  void toggle(String lessonId) {
    HapticFeedback.lightImpact();
    if (state.contains(lessonId)) {
      state = {...state}..remove(lessonId);
      _likeCounts[lessonId] = (_likeCounts[lessonId] ?? 1) - 1;
    } else {
      state = {...state, lessonId};
      _likeCounts[lessonId] = (_likeCounts[lessonId] ?? 0) + 1;
    }
  }
}

final likesProvider = StateNotifierProvider<LikesNotifier, Set<String>>((ref) {
  return LikesNotifier();
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SAVED / BOOKMARKS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SavedNotifier extends StateNotifier<Set<String>> {
  SavedNotifier() : super({});

  bool isSaved(String lessonId) => state.contains(lessonId);

  void toggle(String lessonId) {
    HapticFeedback.mediumImpact();
    if (state.contains(lessonId)) {
      state = {...state}..remove(lessonId);
    } else {
      state = {...state, lessonId};
    }
  }
}

final savedProvider = StateNotifierProvider<SavedNotifier, Set<String>>((ref) {
  return SavedNotifier();
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  FOLLOWS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FollowsNotifier extends StateNotifier<Set<String>> {
  FollowsNotifier() : super({});

  bool isFollowing(String creatorName) => state.contains(creatorName);

  void toggle(String creatorName) {
    HapticFeedback.lightImpact();
    if (state.contains(creatorName)) {
      state = {...state}..remove(creatorName);
    } else {
      state = {...state, creatorName};
    }
  }
}

final followsProvider = StateNotifierProvider<FollowsNotifier, Set<String>>((ref) {
  return FollowsNotifier();
});
