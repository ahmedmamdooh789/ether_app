import 'package:flutter/material.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  final TextEditingController _searchController = TextEditingController();
  
  // List of interest categories
  final List<String> interests = [
    'Technology',
    'Games',
    'Animals',
    'Travel',
    'Learning',
  ];
  
  // Selected interests
  final Set<String> selectedInterests = {'Games', 'Animals'};
  
  // Track which users have had requests sent
  final Set<String> _requestSentUsers = {};
  
  // List of suggested users
  final List<Map<String, dynamic>> suggestedUsers = [
    {
      'username': 'Mona',
      'userImage': null, // No profile pic
      'matchPercentage': 85,
    },
    {
      'username': 'Karim',
      'userImage': null, // No profile pic
      'matchPercentage': 78,
    },
    {
      'username': 'Sara',
      'userImage': null, // No profile pic
      'matchPercentage': 72,
    },
    {
      'username': 'Omar',
      'userImage': null, // No profile pic
      'matchPercentage': 68,
    },
    {
      'username': 'Layla',
      'userImage': null, // No profile pic
      'matchPercentage': 65,
    },
    {
      'username': 'Youssef',
      'userImage': null, // No profile pic
      'matchPercentage': 62,
    },
    {
      'username': 'Nour',
      'userImage': null, // No profile pic
      'matchPercentage': 58,
    },
    {
      'username': 'Hany',
      'userImage': null, // No profile pic
      'matchPercentage': 55,
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
          'suggestions',
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
            icon: const Icon(Icons.person, color: Colors.grey, size: 20),
            onPressed: () {
              // Profile action
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            
            // Interests section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'interest',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // View all interests
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Interest tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  final isSelected = selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedInterests.remove(interest);
                        } else {
                          selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[300] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Suggested users
            Expanded(
              child: ListView.builder(
                itemCount: suggestedUsers.length,
                itemBuilder: (context, index) {
                  final user = suggestedUsers[index];
                  
                  // Filter based on search
                  if (_searchController.text.isNotEmpty &&
                      !user['username'].toString().toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          )) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // User image or placeholder
                        user['userImage'] != null
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
                        
                        // Username and match percentage
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
                                'matching with your interests in ${user['matchPercentage']}%',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Add button or Request Sent button
                        ElevatedButton(
                          onPressed: _requestSentUsers.contains(user['username'])
                              ? null // Disable button if request already sent
                              : () {
                                  // Add friend functionality - change to 'Request Sent'
                                  setState(() {
                                    _requestSentUsers.add(user['username']);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _requestSentUsers.contains(user['username'])
                                ? Colors.grey[400]
                                : primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(100, 36),
                            disabledBackgroundColor: Colors.grey[400],
                            disabledForegroundColor: Colors.white,
                          ),
                          child: Text(
                            _requestSentUsers.contains(user['username']) ? 'Request Sent' : 'Add'
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
  }
}
