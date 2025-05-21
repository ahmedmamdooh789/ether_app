import '../screens/home_screen.dart' as home_screen;

// Import the Comment class directly to avoid using home_screen.Comment
import '../screens/home_screen.dart' show Comment, Post;

/// A service class to manage posts and synchronize comments across different screens.
class PostService {
  // Singleton pattern implementation
  static final PostService _instance = PostService._internal();
  
  factory PostService() {
    return _instance;
  }
  
  PostService._internal();
  
  /// Adds a comment to a post and syncs it across both the main posts list and saved posts list.
  void addComment(String postId, Comment comment) {
    // Sync with saved posts if this post is saved
    final savedPostIndex = home_screen.savedPosts.indexWhere((p) => p.id == postId);
    if (savedPostIndex != -1) {
      // Check if the comment is already in the saved post
      final commentExists = home_screen.savedPosts[savedPostIndex].comments.any(
        (c) => c.username == comment.username && c.text == comment.text
      );
      
      if (!commentExists) {
        home_screen.savedPosts[savedPostIndex].comments.add(comment);
      }
    }
    
    // No need to sync with main posts list as the comment is already added there
    // by the calling code in home_screen.dart
  }
  
  /// Removes a comment from a post and syncs the removal across both lists.
  void removeComment(String postId, Comment comment) {
    // Sync with saved posts if this post is saved
    final savedPostIndex = home_screen.savedPosts.indexWhere((p) => p.id == postId);
    if (savedPostIndex != -1) {
      home_screen.savedPosts[savedPostIndex].comments.removeWhere(
        (c) => c.username == comment.username && c.text == comment.text
      );
    }
    
    // No need to sync with main posts list as the comment is already removed there
    // by the calling code in home_screen.dart
  }
  
  /// Gets a post by its ID from either the main posts list or saved posts list.
  Post? getPostById(String postId) {
    // First check in the main posts list
    for (var post in home_screen.posts) {
      if (post.id == postId) {
        return post;
      }
    }
    
    // Then check in the saved posts list
    for (var post in home_screen.savedPosts) {
      if (post.id == postId) {
        return post;
      }
    }
    
    return null;
  }
  
  /// Updates a post in both lists if it exists.
  void updatePost(Post updatedPost) {
    // Update in main posts list
    final mainPostIndex = home_screen.posts.indexWhere((p) => p.id == updatedPost.id);
    if (mainPostIndex != -1) {
      home_screen.posts[mainPostIndex] = updatedPost;
    }
    
    // Update in saved posts list
    final savedPostIndex = home_screen.savedPosts.indexWhere((p) => p.id == updatedPost.id);
    if (savedPostIndex != -1) {
      home_screen.savedPosts[savedPostIndex] = updatedPost;
    }
  }

  void removeReply(String id, String id2, home_screen.Reply reply) {}

  void addReply(String id, String id2, home_screen.Reply newReply) {}
}
