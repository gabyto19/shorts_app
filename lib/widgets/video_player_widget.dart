import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A full-screen video player widget for the lesson feed.
///
/// Features:
/// - Auto-plays when [isActive] is true, pauses when false
/// - Tap to play/pause with overlay icon
/// - Loops the video
/// - Shows buffering indicator
/// - Falls back to gradient background on error
class LessonVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final List<Color> fallbackGradient;
  final bool isActive;

  const LessonVideoPlayer({
    super.key,
    this.videoUrl,
    required this.fallbackGradient,
    required this.isActive,
  });

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    try {
      final uri = Uri.parse(widget.videoUrl!);
      _controller = VideoPlayerController.networkUrl(uri);

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0); // Muted by default for auto-play

      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.isActive) {
          _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void didUpdateWidget(LessonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive && _isInitialized) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isInitialized || _controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showPlayIcon = true;
      } else {
        _controller!.play();
        _showPlayIcon = false;
      }
    });

    // Auto-hide play icon after 2 seconds
    if (_showPlayIcon) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showPlayIcon) {
          setState(() => _showPlayIcon = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Video or Gradient Fallback ───
          if (_isInitialized && !_hasError)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            // Gradient fallback
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.fallbackGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

          // ─── Buffering Indicator ───
          if (_isInitialized && _controller!.value.isBuffering)
            const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),

          // ─── Loading Indicator (before init) ───
          if (!_isInitialized && !_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading video...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // ─── Play/Pause Icon Overlay ───
          if (_showPlayIcon)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
