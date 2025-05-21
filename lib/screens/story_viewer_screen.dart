import 'package:flutter/material.dart';
import 'dart:io';
import 'home_screen.dart';
import 'dart:async';

class StoryViewerScreen extends StatefulWidget {
  final List<UserStory> userStories;
  final int initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.userStories,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int userIndex;
  late int storyIndex;
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  List<List<bool>> likedStories = [];
  Timer? _timer;
  double _progress = 0.0;
  static const storyDuration = Duration(seconds: 5);
  static const String currentUser = 'Ahmed';

  @override
  void initState() {
    super.initState();
    userIndex = widget.initialUserIndex;
    storyIndex = 0;
    likedStories = widget.userStories
        .map((userStory) => List.generate(userStory.stories.length, (_) => false))
        .toList();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.05 / storyDuration.inSeconds;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    _timer?.cancel();
    setState(() {
      if (storyIndex < widget.userStories[userIndex].stories.length - 1) {
        storyIndex++;
        _startTimer();
      } else if (userIndex < widget.userStories.length - 1) {
        userIndex++;
        storyIndex = 0;
        _startTimer();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _prevStory() {
    _timer?.cancel();
    setState(() {
      if (storyIndex > 0) {
        storyIndex--;
        _startTimer();
      } else if (userIndex > 0) {
        userIndex--;
        storyIndex = widget.userStories[userIndex].stories.length - 1;
        _startTimer();
      }
    });
  }

  void _deleteCurrentStory() {
    setState(() {
      widget.userStories[userIndex].stories.removeAt(storyIndex);
      likedStories[userIndex].removeAt(storyIndex);
      if (widget.userStories[userIndex].stories.isEmpty) {
        widget.userStories.removeAt(userIndex);
        likedStories.removeAt(userIndex);
        if (widget.userStories.isEmpty) {
          Navigator.pop(context);
          return;
        }
        if (userIndex > 0) userIndex--;
        storyIndex = 0;
      } else if (storyIndex >= widget.userStories[userIndex].stories.length) {
        storyIndex = widget.userStories[userIndex].stories.length - 1;
      }
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool invalid = widget.userStories.isEmpty ||
        userIndex < 0 ||
        userIndex >= widget.userStories.length ||
        widget.userStories[userIndex].stories.isEmpty ||
        storyIndex < 0 ||
        storyIndex >= widget.userStories[userIndex].stories.length;

    if (invalid) {
      Future.microtask(() {
        if (mounted) Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }
    final userStory = widget.userStories[userIndex];
    final story = userStory.stories[storyIndex];
    final bool isFile = story.imagePath.startsWith('/') || story.imagePath.contains('storage');
    final bool isCurrentUser = userStory.username == currentUser;
    double dragStartY = 0;
    double dragDistance = 0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < width / 3) {
              _prevStory();
            } else {
              _nextStory();
            }
          },
          onVerticalDragStart: (details) {
            dragStartY = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (details) {
            dragDistance = details.globalPosition.dy - dragStartY;
          },
          onVerticalDragEnd: (details) {
            if (dragDistance > 80) {
              Navigator.pop(context);
            }
          },
          child: Stack(
            children: [
              // Progress bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: List.generate(userStory.stories.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        child: LinearProgressIndicator(
                          value: i < storyIndex
                              ? 1.0
                              : i == storyIndex
                                  ? _progress
                                  : 0.0,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: isFile
                      ? Image.file(
                          File(story.imagePath),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          story.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              // Top user info
              Positioned(
                top: 24,
                left: 24,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(userStory.userImage),
                      radius: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      userStory.username,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                    ),
                  ],
                ),
              ),
              // Story text overlay
              if (story.text != null && story.text!.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      story.text!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              // Heart icon
              Positioned(
                bottom: 32,
                right: 32,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      likedStories[userIndex][storyIndex] = !likedStories[userIndex][storyIndex];
                    });
                  },
                  child: Icon(
                    likedStories[userIndex][storyIndex] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: likedStories[userIndex][storyIndex] ? Colors.pinkAccent : Colors.white,
                    size: 40,
                    shadows: [
                      Shadow(
                        color: likedStories[userIndex][storyIndex] ? Colors.pinkAccent.withOpacity(0.5) : Colors.black45,
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
              // Delete icon (only for your own stories)
              if (isCurrentUser)
                Positioned(
                  top: 24,
                  right: 24,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 28),
                    onPressed: () {
                      _deleteCurrentStory();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 