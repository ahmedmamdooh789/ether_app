import 'package:flutter/material.dart';
import 'home_screen.dart'; // To access Post and savedPosts
import 'dart:io';
import '../data/post_service.dart';

class SavesScreen extends StatefulWidget {
  const SavesScreen({super.key});

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  // Get instance of PostService for comment synchronization
  final PostService _postService = PostService();

  final Map<String, TextEditingController> _commentControllers = {};
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  int? _expandedPost;

  @override
  void dispose() {
    _commentControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Saved Posts',
          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: savedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Posts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posts you save will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPostCard(savedPosts[index]),
                );
              },
            ),
    );
  }

  Widget _buildPostCard(Post post) {
    _commentControllers.putIfAbsent(post.id, () => TextEditingController());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(post.userImage),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              post.userHandle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove from Saved'),
                            content: const Text('Are you sure you want to remove this post from saved?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    post.isSaved = false;
                                    savedPosts.remove(post);
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (post.postImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: post.postImage.startsWith('/') || post.postImage.contains('storage')
                        ? Image.file(
                            File(post.postImage),
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            post.postImage,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                const SizedBox(height: 16),
                Text(
                  post.text,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLikeButton(post),
                _buildCommentButton(post),
                _buildSaveButton(post),
              ],
            ),
          ),
          if (_expandedPost == savedPosts.indexOf(post)) _buildCommentsSection(post),
        ],
      ),
    );
  }

  Widget _buildLikeButton(Post post) {
    return GestureDetector(
      onTap: () {
        setState(() {
          post.isLiked = !post.isLiked;
          post.likes += post.isLiked ? 1 : -1;
        });
      },
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(post.isLiked),
              size: 24,
              color: post.isLiked ? Colors.pinkAccent : Colors.grey,
              shadows: post.isLiked
                  ? [Shadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 8)]
                  : [],
            ),
          ),
          const SizedBox(width: 4),
          Text('${post.likes}'),
        ],
      ),
    );
  }

  Widget _buildCommentButton(Post post) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_expandedPost == savedPosts.indexOf(post)) {
            _expandedPost = null;
          } else {
            _expandedPost = savedPosts.indexOf(post);
          }
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.mode_comment_rounded,
            size: 22,
            color: _expandedPost == savedPosts.indexOf(post) ? primaryPurple : Colors.grey,
            shadows: _expandedPost == savedPosts.indexOf(post)
                ? [Shadow(color: primaryPurple.withOpacity(0.3), blurRadius: 8)]
                : [],
          ),
          const SizedBox(width: 4),
          Text('${post.comments.length}'),
        ],
      ),
    );
  }

  Widget _buildSaveButton(Post post) {
    return GestureDetector(
      onTap: () {
        setState(() {
          post.isSaved = false;
          savedPosts.remove(post);
        });
      },
      child: Icon(
        Icons.bookmark_rounded,
        size: 22,
        color: primaryPurple,
        shadows: [Shadow(color: primaryPurple.withOpacity(0.3), blurRadius: 8)],
      ),
    );
  }

  Widget _buildCommentsSection(Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${post.comments.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...post.comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(c.userImage),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c.username == 'Ahmed')
                            Text(
                              c.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          else
                            Text(
                              c.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            c.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // Add delete icon for the user's own comments
                    if (c.username == 'Ahmed')
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Comment'),
                              content: const Text('Are you sure you want to delete this comment?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      post.comments.remove(c);
                                      
                                      // Sync comment removal with PostService
                                      _postService.removeComment(post.id, c);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.delete_rounded,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              )),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/user2.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentControllers[post.id],
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryPurple.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryPurple),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: primaryPurple),
                  onPressed: () {
                    final text = _commentControllers[post.id]?.text.trim();
                    if (text != null && text.isNotEmpty) {
                      setState(() {
                        post.comments.add(Comment(
                          username: 'Ahmed',
                          userImage: 'assets/user2.png',
                          text: text,
                        ));
                        
                        // Sync the new comment with PostService
                        _postService.addComment(post.id, post.comments.last);
                        
                        _commentControllers[post.id]?.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
