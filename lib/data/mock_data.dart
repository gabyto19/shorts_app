/// Mock data for the entire application.
/// In production, this would come from Firebase/API.

import 'package:flutter/material.dart';

class VideoLesson {
  final String id;
  final String title;
  final String description;
  final String creatorName;
  final String creatorAvatar;
  final int likes;
  final int comments;
  final List<String> hashtags;
  final double progress; // 0.0 to 1.0
  final String duration;
  final String currentTime;
  final List<Color> gradientColors;
  final String? videoUrl;

  const VideoLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorName,
    required this.creatorAvatar,
    required this.likes,
    required this.comments,
    required this.hashtags,
    required this.progress,
    required this.duration,
    required this.currentTime,
    required this.gradientColors,
    this.videoUrl,
  });
}

class Course {
  final String id;
  final String title;
  final String description;
  final String duration;
  final double progress; // 0.0 to 1.0 (-1 for not started)
  final String category;
  final List<Color> gradientColors;
  final bool isNew;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.progress,
    required this.category,
    required this.gradientColors,
    this.isNew = false,
  });

  String get progressText {
    if (progress < 0) return 'NOT STARTED';
    return 'IN PROGRESS';
  }

  String get progressPercent {
    if (progress < 0) return '';
    return '${(progress * 100).toInt()}%';
  }
}

class Creator {
  final String id;
  final String name;
  final String initial;
  final List<Color> avatarColors;

  const Creator({
    required this.id,
    required this.name,
    required this.initial,
    required this.avatarColors,
  });
}

class SavedClip {
  final String id;
  final String title;
  final String category;
  final String timeAgo;
  final List<Color> gradientColors;
  final Color categoryColor;

  const SavedClip({
    required this.id,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.gradientColors,
    required this.categoryColor,
  });
}


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  VIDEO LESSONS (Home Feed)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<VideoLesson> mockVideoLessons = [
  VideoLesson(
    id: '1',
    title: 'Understanding Generative\nAI Models in 2024',
    description: 'A quick dive into how transformers changed the landscape of machine learning.',
    creatorName: 'Prof. Sarah Jenkins',
    creatorAvatar: 'SJ',
    likes: 12500,
    comments: 342,
    hashtags: ['#TechTrends', '#AI', '#DeepLearning'],
    progress: 0.75,
    duration: '1:00',
    currentTime: '0:45',
    gradientColors: [Color(0xFF0D2137), Color(0xFF0A4D68), Color(0xFF088395)],
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ),
  VideoLesson(
    id: '2',
    title: 'Building Scalable\nMicroservices with Go',
    description: 'Learn how to design and deploy microservice architectures using Golang.',
    creatorName: 'Alex Rivera',
    creatorAvatar: 'AR',
    likes: 8900,
    comments: 215,
    hashtags: ['#Golang', '#Backend', '#Architecture'],
    progress: 0.30,
    duration: '1:30',
    currentTime: '0:27',
    gradientColors: [Color(0xFF1A0A2E), Color(0xFF2D1B69), Color(0xFF7B2D8E)],
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
  VideoLesson(
    id: '3',
    title: 'SwiftUI Animations\nMasterclass',
    description: 'Create stunning iOS animations with SwiftUI\'s declarative approach.',
    creatorName: 'Maya Chen',
    creatorAvatar: 'MC',
    likes: 15200,
    comments: 487,
    hashtags: ['#iOS', '#SwiftUI', '#Animation'],
    progress: 0.55,
    duration: '2:00',
    currentTime: '1:06',
    gradientColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ),
  VideoLesson(
    id: '4',
    title: 'React Server Components\nExplained Simply',
    description: 'Understand how RSC changes the way we think about rendering.',
    creatorName: 'David Kim',
    creatorAvatar: 'DK',
    likes: 21300,
    comments: 612,
    hashtags: ['#React', '#Frontend', '#WebDev'],
    progress: 0.10,
    duration: '1:15',
    currentTime: '0:08',
    gradientColors: [Color(0xFF16222A), Color(0xFF3A6073), Color(0xFF283E51)],
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
  VideoLesson(
    id: '5',
    title: 'Intro to Quantum\nComputing for Devs',
    description: 'Quantum computing basics explained through a developer\'s lens.',
    creatorName: 'Dr. Nina Patel',
    creatorAvatar: 'NP',
    likes: 6700,
    comments: 189,
    hashtags: ['#Quantum', '#CompSci', '#Future'],
    progress: 0.92,
    duration: '1:45',
    currentTime: '1:36',
    gradientColors: [Color(0xFF0C0C1D), Color(0xFF1B1464), Color(0xFF6C63FF)],
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  COURSES (Discover > Skill Paths)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final Course featuredCourse = Course(
  id: 'f1',
  title: 'Advanced Neural Networks',
  description: 'Master deep learning architectures with hands-on projects in Python and TensorFlow.',
  duration: '12h 30m',
  progress: -1,
  category: 'AI/ML',
  gradientColors: [Color(0xFF0D2137), Color(0xFF0A4D68), Color(0xFF088395)],
  isNew: true,
);

final List<Course> mockCourses = [
  Course(
    id: 'c1',
    title: 'Full Stack React',
    description: 'Build modern web apps from scratch to...',
    duration: '4h 20m',
    progress: 0.65,
    category: 'Web Dev',
    gradientColors: [Color(0xFF1A237E), Color(0xFF283593)],
  ),
  Course(
    id: 'c2',
    title: 'UI/UX Principles',
    description: 'Design interfaces that users love using Figma.',
    duration: '2h 15m',
    progress: 0.32,
    category: 'Design',
    gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
  ),
  Course(
    id: 'c3',
    title: 'Ethical Hacking',
    description: 'Learn cybersecurity fundamentals &...',
    duration: '8h 45m',
    progress: -1,
    category: 'Security',
    gradientColors: [Color(0xFF004D40), Color(0xFF00695C)],
  ),
  Course(
    id: 'c4',
    title: 'System Design',
    description: 'Architect scalable systems for high traffic.',
    duration: '5h 10m',
    progress: -1,
    category: 'Backend',
    gradientColors: [Color(0xFF3E2723), Color(0xFF5D4037)],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TRENDING TOPICS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<String> trendingTopics = [
  'Trending',
  'Quantum Computing',
  'Web3',
  'AI/ML',
  'Rust',
  'Cloud Native',
  'Flutter',
  'Cybersecurity',
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CREATORS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<Creator> mockCreators = [
  Creator(id: '1', name: 'Sarah Dev', initial: 'S', avatarColors: [Color(0xFF6C63FF), Color(0xFF3F51B5)]),
  Creator(id: '2', name: 'Mike Code', initial: 'M', avatarColors: [Color(0xFF00BFA5), Color(0xFF00897B)]),
  Creator(id: '3', name: 'Anna AI', initial: 'A', avatarColors: [Color(0xFFFF6F61), Color(0xFFE91E63)]),
  Creator(id: '4', name: 'David Data', initial: 'D', avatarColors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
  Creator(id: '5', name: 'Lisa Dev', initial: 'L', avatarColors: [Color(0xFF7C4DFF), Color(0xFF651FFF)]),
  Creator(id: '6', name: 'Ryan ML', initial: 'R', avatarColors: [Color(0xFF00E5FF), Color(0xFF00B8D4)]),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SAVED CLIPS (Notebook)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<SavedClip> mockSavedClips = [
  SavedClip(
    id: 's1',
    title: 'Mastering React Hooks in 2024',
    category: 'React',
    timeAgo: '5m ago',
    gradientColors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
    categoryColor: Color(0xFF2979FF),
  ),
  SavedClip(
    id: 's2',
    title: 'Python Decorators...',
    category: 'Python',
    timeAgo: '2h ago',
    gradientColors: [Color(0xFF33691E), Color(0xFF1B5E20)],
    categoryColor: Color(0xFF76FF03),
  ),
  SavedClip(
    id: 's3',
    title: 'UI Design Principles for...',
    category: 'Design',
    timeAgo: '1d ago',
    gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    categoryColor: Color(0xFFE040FB),
  ),
  SavedClip(
    id: 's4',
    title: 'Intro to Data Science with...',
    category: 'Data',
    timeAgo: '2d ago',
    gradientColors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    categoryColor: Color(0xFF40C4FF),
  ),
  SavedClip(
    id: 's5',
    title: 'Docker vs Kubernetes: Wh...',
    category: 'DevOps',
    timeAgo: '3d ago',
    gradientColors: [Color(0xFF004D40), Color(0xFF00695C)],
    categoryColor: Color(0xFF00E5FF),
  ),
  SavedClip(
    id: 's6',
    title: 'Flutter 3.0: What\'s New?',
    category: 'Mobile',
    timeAgo: '4d ago',
    gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    categoryColor: Color(0xFF69F0AE),
  ),
];
