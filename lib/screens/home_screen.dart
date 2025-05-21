import 'package:ether_app/screens/login_screen.dart';
import 'package:ether_app/screens/add_story_screen.dart';
import 'package:flutter/material.dart';
import 'saves_screen.dart';
import 'friends_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'language_screen.dart';
import 'matching_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ether_app/screens/story_viewer_screen.dart';
import '../data/post_service.dart';



class Story {
  final String imagePath;
  final String? text;
  Story({required this.imagePath, this.text});
}

class UserStory {
  final String userImage;
  final String username;
  final List<Story> stories;
  UserStory({required this.userImage, required this.username, required this.stories});
}

List<UserStory> userStories = [
  UserStory(
    userImage: 'assets/user2.png',
    username: 'Ahmed',
    stories: [Story(imagePath: 'assets/post1.jpg', text: 'Enjoying a sunny day!')],
  ),
  UserStory(
    userImage: 'assets/user3.png',
    username: 'Feky',
    stories: [Story(imagePath: 'assets/post2.jpg')],
  ),
  UserStory(
    userImage: 'assets/user4.png',
    username: 'Sheta',
    stories: [Story(imagePath: 'assets/post3.jpg')],
  ),
];

class Post {
  final String id;
  final String username;
  final String userHandle;
  final String userImage;
  final String postImage;
  final String text;
  List<Comment> comments;
  int likes;
  bool isLiked;
  bool isSaved;

  Post({
    required this.id,
    required this.username,
    required this.userHandle,
    required this.userImage,
    required this.postImage,
    required this.text,
    List<Comment>? comments,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
  }) : this.comments = comments ?? [];
}

class Comment {
  final String id;
  final String username;
  final String userImage;
  final String text;
  final List<Reply> replies;
  final DateTime timestamp;

  Comment({
    required this.username,
    required this.userImage,
    required this.text,
    String? id,
    List<Reply>? replies,
    DateTime? timestamp,
  }) : 
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    this.replies = replies ?? [],
    this.timestamp = timestamp ?? DateTime.now();
    
  // Ensure replies is never null
  List<Reply> get safeReplies => replies;
}

class Reply {
  final String id;
  final String username;
  final String userImage;
  final String text;
  final DateTime timestamp;
  final String replyingTo;

  Reply({
    required this.username,
    required this.userImage,
    required this.text,
    required this.replyingTo,
    String? id,
    DateTime? timestamp,
  }) : 
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    this.timestamp = timestamp ?? DateTime.now();
}

// Global lists to store posts and saved posts for access across the app
List<Post> posts = [
  Post(
    id: '1',
    username: 'Ahmed',
    userHandle: '@Ahmed',
    userImage: 'assets/user2.png',
    postImage: 'assets/post1.jpg',
    text: 'Enjoying a sunny day at the park!',
    comments: [
      Comment(username: 'Feky', userImage: 'assets/user3.png', text: 'Nice!'),
      Comment(username: 'Sheta', userImage: 'assets/user4.png', text: 'Looks fun!'),
      Comment(username: 'Ahmed', userImage: 'assets/user2.png', text: 'Great photo!'),
    ],
    likes: 12,
  ),
  Post(
    id: '2',
    username: 'Feky',
    userHandle: '@Feky',
    userImage: 'assets/user3.png',
    postImage: 'assets/post2.jpg',
    text: 'Check out this amazing sunset.',
    comments: [
      Comment(username: 'Ahmed', userImage: 'assets/user2.png', text: 'Wow!'),
      Comment(username: 'Sheta', userImage: 'assets/user4.png', text: 'Beautiful!'),
      Comment(username: 'Feky', userImage: 'assets/user3.png', text: 'Love this!'),
    ],
    likes: 8,
  ),
  Post(
    id: '3',
    username: 'Sheta',
    userHandle: '@Sheta',
    userImage: 'assets/user4.png',
    postImage: 'assets/post3.jpg',
    text: 'Birthday party vibes 🎉',
    comments: [
      Comment(username: 'Ahmed', userImage: 'assets/user2.png', text: 'Happy Birthday!'),
      Comment(username: 'Feky', userImage: 'assets/user3.png', text: 'Party time!'),
      Comment(username: 'Sheta', userImage: 'assets/user4.png', text: '🎂🎈'),
    ],
    likes: 20,
  ),
];

List<Post> savedPosts = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  // Static user bio that can be updated from other screens
  static String userBio = "Hi, I'm Ahmed! I love technology, gaming, and making new friends. Always looking for new adventures and connections.";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get instance of PostService for comment synchronization
  final PostService _postService = PostService();
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Using the global posts list instead of a class member

  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, TextEditingController> _replyControllers = {};
  
  // Access user bio from the static field
  
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);

  File? selectedImage;
  final TextEditingController postController = TextEditingController();

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentControllers.forEach((_, c) => c.dispose());
    _replyControllers.forEach((_, c) => c.dispose());
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Center(
          child: Image.asset(
            'assets/logo.png',
            height: 150,
            width: 150,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            color: primaryPurple,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30, color: primaryPurple),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.asset(
                  'assets/user2.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('@Ahmed', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            ..._buildDrawerItemList(primaryPurple),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeFeed(),
          _buildCreatePostSection(),
          const Center(child: Text("Search Page", style: TextStyle(fontSize: 22))),
          _buildProfilePage(),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _modernNavIcon(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _modernNavIcon(index: 1, icon: Icons.add_box_rounded, label: 'Post'),
              _modernNavIcon(index: 3, icon: Icons.person_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeFeed() {
    return RefreshIndicator(
      color: primaryPurple,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 50,
      onRefresh: () async {
        // Simulate a network request
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Update the UI
        setState(() {
          // Shuffle the order of posts to simulate new content
          final tempPosts = List<Post>.from(posts);
          tempPosts.shuffle();
          posts.clear();
          posts.addAll(tempPosts);
        });
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: false,
            floating: true,
            expandedHeight: 120,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildStoriesSection(primaryPurple),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildPostCard(index),
                );
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(int postIndex) {
    final post = posts[postIndex];
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
                    if (post.username == 'Ahmed')
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text('Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      posts.removeAt(postIndex);
                                      savedPosts.removeWhere((p) => p.id == post.id);
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
                _buildLikeButton(postIndex),
                _buildCommentButton(postIndex),
                _buildSaveButton(postIndex),
              ],
            ),
          ),
          if (_expandedPost == postIndex) _buildCommentsSection(postIndex),
        ],
      ),
    );
  }

  Widget _buildLikeButton(int postIndex) {
    final post = posts[postIndex];
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

  Widget _buildCommentButton(int postIndex) {
    final post = posts[postIndex];
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle comments section
          if (_expandedPost == postIndex) {
            _expandedPost = null;
          } else {
            _expandedPost = postIndex;
          }
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.mode_comment_rounded,
            size: 22,
            color: _expandedPost == postIndex ? primaryPurple : Colors.grey,
            shadows: _expandedPost == postIndex
                ? [Shadow(color: primaryPurple.withOpacity(0.3), blurRadius: 8)]
                : [],
          ),
          const SizedBox(width: 4),
          Text('${post.comments.length}'),
        ],
      ),
    );
  }

  int? _expandedPost;

  Widget _buildSaveButton(int postIndex) {
    final post = posts[postIndex];
    return GestureDetector(
      onTap: () {
        setState(() {
          post.isSaved = !post.isSaved;
          if (post.isSaved) {
            if (!savedPosts.any((p) => p.id == post.id)) {
              savedPosts.add(post);
            }
          } else {
            savedPosts.removeWhere((p) => p.id == post.id);
          }
        });
      },
      child: Icon(
        post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 22,
        color: post.isSaved ? primaryPurple : Colors.grey,
        shadows: post.isSaved
            ? [Shadow(color: primaryPurple.withOpacity(0.3), blurRadius: 8)]
            : [],
      ),
    );
  }

  // Track which comment we're replying to
  String? _replyingToCommentId;
  
  Widget _buildCommentsSection(int postIndex) {
    if (_expandedPost != postIndex) return const SizedBox.shrink();
    final post = posts[postIndex];
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
          ...post.comments.map((c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: c.safeReplies.isEmpty ? 12 : 8),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatTimestamp(c.timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (_replyingToCommentId == c.id) {
                                              _replyingToCommentId = null;
                                            } else {
                                              _replyingToCommentId = c.id;
                                              _replyControllers.putIfAbsent(c.id, () => TextEditingController());
                                            }
                                          });
                                        },
                                        child: Text(
                                          _replyingToCommentId == c.id ? 'Cancel' : 'Reply',
                                          style: TextStyle(
                                            color: primaryPurple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (c.safeReplies.isNotEmpty)
                                        Text(
                                          '${c.safeReplies.length} ${c.safeReplies.length == 1 ? 'reply' : 'replies'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
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
                                              posts[postIndex].comments.remove(c);
                                              _postService.removeComment(posts[postIndex].id, c);
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
                        // Reply input field
                        if (_replyingToCommentId == c.id)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage('assets/user2.png'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _replyControllers[c.id],
                                    decoration: InputDecoration(
                                      hintText: 'Reply to ${c.username}...',
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
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
                                  icon: Icon(Icons.send_rounded, color: primaryPurple, size: 20),
                                  onPressed: () {
                                    final text = _replyControllers[c.id]?.text.trim();
                                    if (text != null && text.isNotEmpty) {
                                      setState(() {
                                        Reply newReply = Reply(
                                          username: 'Ahmed',
                                          userImage: 'assets/user2.png',
                                          text: text,
                                          replyingTo: c.username,
                                        );
                                        // Add reply and sync with PostService
                                        c.safeReplies.add(newReply);
                                        _postService.addReply(post.id, c.id, newReply);
                                        _replyControllers[c.id]?.clear();
                                        _replyingToCommentId = null;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Display replies with indentation
                  if (c.safeReplies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: c.safeReplies.map((reply) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(reply.userImage),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: reply.username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' replying to ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              TextSpan(
                                                text: reply.replyingTo,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: primaryPurple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatTimestamp(reply.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reply.text,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // Delete option for own replies
                              if (reply.username == 'Ahmed')
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Reply'),
                                        content: const Text('Are you sure you want to delete this reply?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                c.replies.remove(reply);
                                                // Sync with PostService
                                                _postService.removeReply(post.id, c.id, reply);
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
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.delete_rounded,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                ],
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
                        Comment newComment = Comment(
                          username: 'Ahmed',
                          userImage: 'assets/user2.png',
                          text: text,
                        );
                        posts[postIndex].comments.add(newComment);
                        // Sync the new comment with PostService
                        _postService.addComment(posts[postIndex].id, newComment);
                        // No need to manually sync with savedPosts as PostService handles this
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

  // Helper method to format timestamps for comments and replies
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildStoriesSection(Color primaryPurple) {
    // Assume current user is 'Ahmed' with userImage 'assets/user2.png'
    final String currentUser = 'Ahmed';
    final String currentUserImage = 'assets/user2.png';
    final currentUserStoryIndex = userStories.indexWhere((us) => us.username == currentUser);
    final hasCurrentUserStory = currentUserStoryIndex != -1 && userStories[currentUserStoryIndex].stories.isNotEmpty;

    final otherUsers = userStories.where((us) => us.username != currentUser).toList();
    int itemCount = 1 + otherUsers.length;

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Show user's story circle with add button
            return Stack(
              children: [
                // Main circle for viewing stories
                GestureDetector(
                  onTap: hasCurrentUserStory ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryViewerScreen(
                          userStories: userStories,
                          initialUserIndex: currentUserStoryIndex,
                        ),
                      ),
                    );
                    setState(() {});
                  } : null,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasCurrentUserStory 
                            ? LinearGradient(colors: [primaryPurple, Colors.purple])
                            : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: AssetImage(currentUserImage),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add story button
                Positioned(
                  bottom: 20,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddStoryScreen(onStoryAdded: (imagePath, text) {
                            setState(() {
                              final idx = userStories.indexWhere((us) => us.username == currentUser);
                              if (idx == -1) {
                                userStories.insert(0, UserStory(
                                  userImage: currentUserImage,
                                  username: currentUser,
                                  stories: [Story(imagePath: imagePath, text: text)],
                                ));
                              } else {
                                userStories[idx].stories.add(Story(imagePath: imagePath, text: text));
                              }
                            });
                          }),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Other users' stories
            final otherUserIndex = index - 1;
            final userStory = otherUsers[otherUserIndex];
            return GestureDetector(
              onTap: () async {
                if (userStory.stories.isNotEmpty) {
                  final realIndex = userStories.indexWhere((us) => us.username == userStory.username);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(
                        userStories: userStories,
                        initialUserIndex: realIndex,
                      ),
                    ),
                  );
                  setState(() {});
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryPurple, Colors.purple],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 33,
                        backgroundColor: null,
                        backgroundImage: AssetImage(userStory.userImage),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userStory.username,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildDrawerItemList(Color color) {
    final items = [
      {'label': 'Edit Profile', 'icon': Icons.edit},
      {'label': 'Saves', 'icon': Icons.bookmark},
      {'label': 'Friends', 'icon': Icons.group},
      {'label': 'Matching', 'icon': Icons.favorite},
      {'label': 'Search', 'icon': Icons.search},
      {'label': 'Language', 'icon': Icons.language},
      {'label': 'Logout', 'icon': Icons.logout},
    ];

    return items.map((item) {
      final String label = item['label'] as String;
      final IconData icon = item['icon'] as IconData;
      final bool isLogout = label == 'Logout';
      final bool isEditProfile = label == 'Edit Profile';
      final bool isSaves = label == 'Saves';
      final bool isFriends = label == 'Friends';
      final bool isMatching = label == 'Matching';
      final bool isSearch = label == 'Search';
      final bool isLanguage = label == 'Language';

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        leading: Icon(icon, color: color),
        onTap: isLogout
            ? _logout
            : isEditProfile
                ? () {
                    Navigator.pushNamed(context, '/editprofile');
                  }
                : isSaves
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SavesScreen()),
                        );
                      }
                    : isFriends
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FriendsScreen()),
                            );
                          }
                        : isMatching
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => MatchingScreen()),
                                );
                              }
                            : isSearch
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => SearchScreen()),
                                    );
                                  }
                                : isLanguage
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => LanguageScreen()),
                                        );
                                      }
                                    : () => print('$label tapped'),
      );
    }).toList();
  }

  Widget _modernNavIcon({required int index, required IconData icon, required String label}) {
    final bool isSelected = _selectedIndex == index;
    final Color selectedColor = primaryPurple;
    final Color unselectedColor = Colors.grey[400]!;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: isSelected ? 32 : 26,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                fontSize: isSelected ? 15 : 13,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    final List<Post> ahmedPosts = posts.where((p) => p.username == 'Ahmed').toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 40, bottom: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/user2.png'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ahmed',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@Ahmed',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    HomeScreen.userBio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _profileTag('games'),
                    _profileTag('technology'),
                    _profileTag('learning'),
                    _profileTag('Travel'),
                    _profileTag('Animals'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _profileStat('100', 'Post'),
                      _profileStat('70%', 'Matching'),
                      _profileStat('10k', 'Friends'),
                      _profileStat('64', 'Mutual Friends'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                ...ahmedPosts.map((post) => _buildProfilePostCard(post)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTag(String tag) {
    return Chip(
      label: Text(tag, style: const TextStyle(color: Colors.purple)),
      backgroundColor: const Color(0xFFF3EFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _profileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }

  Widget _buildProfilePostCard(Post post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
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
                  if (post.postImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: post.postImage.startsWith('/') || post.postImage.contains('storage')
                          ? Image.file(
                              File(post.postImage),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              post.postImage,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    post.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLikeButton(posts.indexOf(post)),
                  _buildCommentButton(posts.indexOf(post)),
                  Row(
                    children: [
                      _buildSaveButton(posts.indexOf(post)),
                      if (post.username == 'Ahmed')
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text('Are you sure you want to delete this post?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        posts.removeWhere((p) => p.id == post.id);
                                        savedPosts.removeWhere((p) => p.id == post.id);
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
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_expandedPost == posts.indexOf(post)) _buildCommentsSection(posts.indexOf(post)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    Future<void> pickImage() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Create Post',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('assets/user2.png'),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ahmed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '@Ahmed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: postController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image, color: primaryPurple),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(color: primaryPurple),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (postController.text.isNotEmpty) {
                              final String newPostId = DateTime.now().millisecondsSinceEpoch.toString();
                              setState(() {
                                // Create a new post with an empty comments list
                                Post newPost = Post(
                                  id: newPostId,
                                  username: 'Ahmed',
                                  userHandle: '@Ahmed',
                                  userImage: 'assets/user2.png',
                                  postImage: selectedImage != null ? selectedImage!.path : '',
                                  text: postController.text,
                                  comments: [], // Initialize with an empty list
                                );
                                
                                // Add the post to the beginning of the list
                                posts.insert(0, newPost);
                                
                                // Initialize the comment controller for the new post
                                _commentControllers[newPostId] = TextEditingController();
                                
                                postController.clear();
                                selectedImage = null;
                                _pageController.jumpToPage(0);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
