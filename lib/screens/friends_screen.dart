import 'package:flutter/material.dart';
import 'suggestions_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  final TextEditingController _searchController = TextEditingController();
  
  // List of friends
  List<Map<String, dynamic>> _friends = [
    {
      'username': 'Feky',
      'userImage': 'assets/user3.png',
      'userHandle': '@Feky',
      'isOnline': true,
    },
    {
      'username': 'Sheta',
      'userImage': 'assets/user4.png',
      'userHandle': '@Sheta',
      'isOnline': false,
    },
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Friends',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.grey, size: 20),
            onPressed: () {
              // Navigate to suggestions screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
              ).then((value) {
                // Refresh the screen when returning from suggestions
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: Column(
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
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey[500], size: 20),
                    onPressed: () {
                      // Filter action
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Friends list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final user = _friends[index];
                
                // Filter based on search
                if (_searchController.text.isNotEmpty &&
                    !user['username'].toString().toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        )) {
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // User image or placeholder
                      user.containsKey('userImage') && user['userImage'] != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(user['userImage']),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                user['username'][0],
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(width: 12),
                      
                      // Username and handle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['username'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user['userHandle'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Unfriend button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Remove from friends list
                            _friends.removeAt(index);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Unfriend'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
