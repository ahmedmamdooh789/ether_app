import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../models/post.dart';
import '../api/post_service.dart';

@lazySingleton
class PostProvider extends ChangeNotifier {
  final PostService _postService;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  
  PostProvider(this._postService);
  
  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  
  // Load posts with pagination
  Future<void> loadPosts({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _posts = [];
    } else if (!_hasMore) {
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPosts = await _postService.getPosts(page: _currentPage);
      
      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }
      
      _hasMore = newPosts.isNotEmpty;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new post
  Future<bool> createPost(String content, {List<String>? mediaUrls, List<String>? imageUrls}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPost = await _postService.createPost(
        content: content,
        mediaUrls: mediaUrls,
      );
      _posts.insert(0, newPost);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index == -1) return;
      
      final post = _posts[index];
      final updatedPost = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      
      _posts[index] = updatedPost;
      notifyListeners();
      
      // Call API
      if (updatedPost.isLiked) {
        await _postService.likePost(postId);
      } else {
        await _postService.unlikePost(postId);
      }
    } catch (e) {
      // Revert changes on error
      notifyListeners();
      rethrow;
    }
  }
  
  // Add comment to a post
  Future<void> addComment(String postId, String content) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index == -1) return;
      
      // Add comment via API
      await _postService.addComment(postId, content);
      
      // Update local post with incremented comment count
      final post = _posts[index];
      _posts[index] = post.incrementCommentCount();
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
