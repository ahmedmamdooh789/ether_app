import 'package:flutter/material.dart';
import 'dart:io'; // For File class
import 'home_screen.dart'; // To access posts and users

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  
  // List of people to search through (combining users from posts and stories)
  final List<Map<String, dynamic>> _people = [
    {
      'username': 'Feky',
      'userImage': 'assets/user3.png',
      'userHandle': '@Feky',
      'bio': 'Photographer and travel enthusiast',
      'isFollowing': true,
    },
    {
      'username': 'Sheta',
      'userImage': 'assets/user4.png',
      'userHandle': '@Sheta',
      'bio': 'Digital artist | Music lover',
      'isFollowing': true,
    },
    {
      'username': 'Mona',
      'userImage': null,
      'userHandle': '@mona',
      'bio': 'Food blogger and cooking enthusiast',
      'isFollowing': false,
    },
    {
      'username': 'Karim',
      'userImage': null,
      'userHandle': '@karim',
      'bio': 'Tech geek | Software developer',
      'isFollowing': false,
    },
    {
      'username': 'Sara',
      'userImage': null,
      'userHandle': '@sara',
      'bio': 'Fitness instructor | Healthy lifestyle',
      'isFollowing': false,
    },
    {
      'username': 'Omar',
      'userImage': null,
      'userHandle': '@omar',
      'bio': 'Travel vlogger | Adventure seeker',
      'isFollowing': false,
    },
    {
      'username': 'Layla',
      'userImage': null,
      'userHandle': '@layla',
      'bio': 'Fashion designer | Style enthusiast',
      'isFollowing': false,
    },
    {
      'username': 'Youssef',
      'userImage': null,
      'userHandle': '@youssef',
      'bio': 'Music producer | Guitar player',
      'isFollowing': false,
    },
    {
      'username': 'Nour',
      'userImage': null,
      'userHandle': '@nour',
      'bio': 'Book lover | Coffee addict',
      'isFollowing': false,
    },
    {
      'username': 'Hany',
      'userImage': null,
      'userHandle': '@hany',
      'bio': 'Sports fan | Basketball player',
      'isFollowing': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[500], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for people or posts',
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: primaryPurple,
                labelColor: primaryPurple,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'People'),
                  Tab(text: 'Posts'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // People tab
          _buildPeopleTab(),
          
          // Posts tab
          _buildPostsTab(),
        ],
      ),
    );
  }
  
  Widget _buildPeopleTab() {
    // Filter people based on search query
    final filteredPeople = _searchQuery.isEmpty
        ? _people
        : _people.where((person) {
            return person['username'].toLowerCase().contains(_searchQuery) ||
                   person['userHandle'].toLowerCase().contains(_searchQuery) ||
                   person['bio'].toLowerCase().contains(_searchQuery);
          }).toList();
    
    if (filteredPeople.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No people found for "$_searchQuery"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPeople.length,
      itemBuilder: (context, index) {
        final person = filteredPeople[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // User image or placeholder
              person['userImage'] != null
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(person['userImage']),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        person['username'][0],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person['userHandle'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      person['bio'],
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Follow/Following button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Toggle following status
                    person['isFollowing'] = !person['isFollowing'];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: person['isFollowing'] ? Colors.grey[300] : primaryPurple,
                  foregroundColor: person['isFollowing'] ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(person['isFollowing'] ? 'Following' : 'Follow'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPostsTab() {
    // Create a local copy of posts with proper initialization
    final List<Post> filteredSourcePosts = posts.map((post) => Post(
      id: post.id,
      username: post.username,
      userHandle: post.userHandle,
      userImage: post.userImage,
      postImage: post.postImage,
      text: post.text,
      comments: post.comments,
      likes: post.likes,
      isLiked: post.isLiked,
      isSaved: post.isSaved,
    )).toList();
    
    // Filter posts based on search query
    final filteredPosts = _searchQuery.isEmpty
        ? filteredSourcePosts
        : filteredSourcePosts.where((post) {
            return post.text.toLowerCase().contains(_searchQuery) ||
                   post.username.toLowerCase().contains(_searchQuery);
          }).toList();
    
    if (filteredPosts.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No posts found for "$_searchQuery"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                                          filteredSourcePosts.removeWhere((p) => p.id == post.id);
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
                    // Like button
                    Row(
                      children: [
                        GestureDetector(
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
                              const SizedBox(width: 8),
                              Text(
                                '${post.likes}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Comment button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Create a variable to track which post has its comments expanded
                            // Show comments dialog with animation
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                height: MediaQuery.of(context).size.height * 0.75,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'Comments (${post.comments.length})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: post.comments.length,
                                        itemBuilder: (context, index) {
                                          final comment = post.comments[index];
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: AssetImage(comment.userImage),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        comment.username,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        comment.text,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  Icons.mode_comment_rounded,
                                  key: ValueKey(post.id),
                                  size: 22,
                                  color: Colors.grey[700],
                                  shadows: [],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${post.comments.length}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Save button
                    GestureDetector(
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          key: ValueKey(post.isSaved),
                          size: 22,
                          color: post.isSaved ? primaryPurple : Colors.grey[700],
                          shadows: post.isSaved
                              ? [Shadow(color: primaryPurple.withOpacity(0.3), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
