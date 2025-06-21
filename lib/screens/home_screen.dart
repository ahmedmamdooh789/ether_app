import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/post_provider.dart';
import '../providers/story_provider.dart';
import '../models/story.dart';
import 'login_screen.dart';
import 'friends_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'story_viewer_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  // Static user bio that can be updated from other screens
  static String userBio = ""; // Will be set from user's bio in API

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, TextEditingController> _replyControllers = {};
  final ScrollController _scrollController = ScrollController();
  String? _expandedPostId; // Use post ID instead of index
  File? selectedPostImage;
  final TextEditingController postController = TextEditingController();
  
  // State management through Provider
  late final StoryProvider storyProvider;
  late final PostProvider postProvider;
  late final Color primaryPurple;

  @override
  void initState() {
    super.initState();
    storyProvider = Provider.of<StoryProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    primaryPurple = Provider.of<AuthProvider>(context, listen: false).appConfig?.primaryColor ?? const Color.fromRGBO(148, 15, 252, 1);
    
    _loadInitialPosts();
    _loadInitialStories();
  }
  


  Future<void> _loadInitialStories() async {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    await storyProvider.loadStories(refresh: true);
  }

  Future<void> _loadMoreStories() async {
    if (storyProvider.isLoading) return;
    
    try {
      await storyProvider.loadStories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load more stories'),
          backgroundColor: Colors.red,
        ),
      );
    }
    } catch (e) {
      setState(() {
        _isStoriesLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load more stories'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadInitialPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.loadPosts(refresh: true);
  }
  
  Future<void> _loadMorePosts() async {
    if (postProvider.isLoading) return;
    
    try {
      await postProvider.loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load more posts'),
          backgroundColor: Colors.red,
        ),
      );
    }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load more posts'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
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
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Center(
              child: Image.network(
                AuthProvider(context).appConfig?.logoUrl ?? '',
                height: 150,
                width: 150,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              _buildHomeScreen(postProvider),
              const SearchScreen(),
              const StoryViewerScreen(),
              const FriendsScreen(),
              const ProfileScreen(),
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
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _modernNavIcon(index: 0, icon: Icons.home_rounded, label: 'Home'),
                  _modernNavIcon(index: 1, icon: Icons.search_rounded, label: 'Search'),
                  _modernNavIcon(index: 2, icon: Icons.add_box_rounded, label: 'Create'),
                  _modernNavIcon(index: 3, icon: Icons.people_alt_rounded, label: 'Friends'),
                  _modernNavIcon(index: 4, icon: Icons.person_rounded, label: 'Profile'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeScreen(PostProvider postProvider) {
    if (postProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postProvider.error != null) {
      return Center(
        child: Text('Error: ${postProvider.error}'),
      );
    }

    return RefreshIndicator(
      color: primaryPurple,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 50,
      onRefresh: () async {
        await postProvider.loadPosts(refresh: true);
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
              title: Text(
                'Stories',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildPostCard(postProvider.posts[index]),
                );
              },
              childCount: postProvider.posts.length,
            ),
          ),
        ],
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
                          backgroundImage: NetworkImage(post.user.profilePictureUrl ?? ''),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.user.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '@${post.user.username}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (post.user.id?.isNotEmpty == true && post.user.id == AuthProvider(context).currentUser?.id)
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey),
                        onPressed: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text('Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (result == true) {
                            final postProvider = Provider.of<PostProvider>(context, listen: false);
                            try {
                              await postProvider.deletePost(post.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to delete post'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: NetworkImage(
                      post.imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  post.content,
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
                _buildLikeButton(post, postProvider),
                _buildCommentButton(post, postProvider),
                _buildSaveButton(post, postProvider),
              ],
            ),
          ),
          if (_expandedPostId == post.id) _buildCommentsSection(post.id),
        ],
      ),
    );
  }

  Widget _buildLikeButton(Post post, PostProvider postProvider) {
    return GestureDetector(
      onTap: () async {
        try {
          await postProvider.toggleLike(post.id);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to like/unlike post'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          Text('${post.likesCount}'),
        ],
      ),
    );
  }

  Widget _buildCommentButton(Post post, PostProvider postProvider) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle comments section
          if (_expandedPost == post.id) {
            _expandedPost = null;
          } else {
            _expandedPost = post.id;
          }
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.mode_comment_rounded,
            size: 22,
            color: _expandedPost == post.id ? primaryPurple : Colors.grey,
            shadows: _expandedPost == post.id
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

  Widget _buildSaveButton(Post post, PostProvider postProvider) {
    return GestureDetector(
      onTap: () async {
        try {
          await postProvider.toggleSave(post.id);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save/unsave post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Icon(
        post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 22,
        color: post.isSaved ? primaryPurple : Colors.grey,
      ),
    );
  }

  // Track which comment we're replying to
  String? _replyingToCommentId;
  
  Widget _buildCommentsSection(String postId) {
    if (_expandedPostId != postId) return const SizedBox.shrink();
    final post = Provider.of<PostProvider>(context, listen: false).posts.firstWhere((p) => p.id == postId);
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
                              backgroundImage: NetworkImage(c.user.profilePictureUrl ?? ''),
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
                                        c.user.username,
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
                                              _replyControllers[c.id]?.clear();
                                            } else {
                                              _replyingToCommentId = c.id;
                                              _replyControllers.putIfAbsent(c.id, () => TextEditingController());
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.reply_rounded,
                                              size: 14,
                                              color: primaryPurple,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _replyingToCommentId == c.id ? 'Cancel' : 'Reply',
                                              style: TextStyle(
                                                color: primaryPurple,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (c.safeReplies.isNotEmpty)
                                        Text(
                                          '${c.replies.length} ${c.replies.length == 1 ? 'reply' : 'replies'}',
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
                            if (c.user.id == AuthProvider(context).currentUser?.id)
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
                                          onPressed: () async {
                                            try {
                                              final postProvider = Provider.of<PostProvider>(context, listen: false);
                                              await postProvider.deleteComment(post.id, c.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Comment deleted successfully'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Failed to delete comment'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              Navigator.pop(context);
                                            }
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
                                  backgroundImage: NetworkImage(AuthProvider(context).currentUser?.profilePictureUrl ?? ''),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _replyControllers[c.id],
                                    decoration: InputDecoration(
                                      hintText: 'Reply to ${c.user.username}...',
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
                                        borderSide: BorderSide(color: AuthProvider(context).appConfig?.primaryColor ?? primaryPurple),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send_rounded, color: primaryPurple, size: 20),
                                  onPressed: () {
                                    final text = _replyControllers[c.id]?.text.trim();
                                    if (text != null && text.isNotEmpty) {
                                      try {
                                        final postProvider = Provider.of<PostProvider>(context, listen: false);
                                        await postProvider.addReply(post.id, c.id, text);
                                        _replyControllers[c.id]?.clear();
                                        _replyingToCommentId = null;
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to add reply: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
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
                  if (c.replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: c.replies.map((reply) => Container(
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
                                backgroundImage: NetworkImage(reply.user.profilePictureUrl ?? ''),
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
                                                  color: AuthProvider(context).appConfig?.primaryColor ?? primaryPurple,
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
                              if (reply.username == AuthProvider(context).currentUser?.username)
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
                                            onPressed: () async {
                                              try {
                                                final postProvider = Provider.of<PostProvider>(context, listen: false);
                                                await postProvider.removeReply(post.id, c.id, reply.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Reply deleted successfully'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Failed to delete reply'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              } finally {
                                                Navigator.pop(context);
                                              }
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
                  backgroundImage: NetworkImage(AuthProvider(context).currentUser?.profilePictureUrl ?? ''),
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
                  onPressed: () async {
                    final text = _commentControllers[post.id]?.text.trim();
                    if (text != null && text.isNotEmpty) {
                      try {
                        final postProvider = Provider.of<PostProvider>(context, listen: false);
                        await postProvider.addComment(post.id, text);
                        _commentControllers[post.id]?.clear();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add comment: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
    final currentUser = AuthProvider(context).currentUser?.username ?? '';
    final currentUserImage = AuthProvider(context).currentUser?.profilePictureUrl ?? '';
    final storyProvider = Provider.of<StoryProvider>(context, listen: true);
    
    if (storyProvider.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (storyProvider.error != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('Error: ${storyProvider.error}'),
        ),
      );
    }

    final currentUserStory = storyProvider.stories.firstWhere(
      (story) => story.username == currentUser,
      orElse: () => const Story(username: '', stories: []),
    );
    final hasCurrentUserStory = currentUserStory.stories.isNotEmpty;

    final otherUsers = storyProvider.stories.where((story) => story.username != currentUser).toList();
    final itemCount = 1 + otherUsers.length;

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
                        builder: (_) => const StoryViewerScreen(),
                      ),
                    );
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
                            backgroundImage: NetworkImage(currentUserImage),
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
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddStoryScreen(),
                        ),
                      );
                      
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Story added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoryViewerScreen(),
                    ),
                  );
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
                        backgroundImage: NetworkImage(userStory.userImage),
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
                      _buildSaveButton(posts.indexOf(post), Provider.of<PostProvider>(context, listen: false)),
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
                                    onPressed: () async {
                                      try {
                                        final postProvider = Provider.of<PostProvider>(context, listen: false);
                                        await postProvider.deletePost(post.id);
                                        Navigator.pop(context);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to delete post: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
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
            if (_expandedPostId == post.id) _buildCommentsSection(post.id),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    Future<void> _pickImage() async {
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
            selectedPostImage = File(image.path);
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
                          backgroundImage: NetworkImage(
                            AuthProvider(context).currentUser?.profilePictureUrl ?? '',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthProvider(context).currentUser?.username ?? 'User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '@${AuthProvider(context).currentUser?.username ?? 'user'}',
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
                    if (selectedPostImage != null)
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
                                  selectedPostImage = null;
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
                              final postProvider = Provider.of<PostProvider>(context, listen: false);
                              postProvider.createPost(
                                postController.text,
                                imageUrls: selectedPostImage != null ? [selectedPostImage!.path] : null,
                              ).then((success) {
                                if (success) {
                                  postController.clear();
                                  setState(() {
                                    postImage = null;
                                  });
                                  _pageController.jumpToPage(0);
                                } else {
                                  // Show error message if post creation fails
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to create post'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
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
