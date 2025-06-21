import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/api_error_handler.dart';
import '../config/environment.dart';

@injectable
class PostService {
  final Dio _dio;

  PostService(this._dio);

  /// Creates a new post
  Future<Post> createPost({
    required String content,
    List<String>? mediaUrls,
  }) async {
    try {
      final response = await _dio.post(
        '/posts',
        data: {
          'content': content,
          if (mediaUrls != null && mediaUrls.isNotEmpty) 'media': mediaUrls,
        },
      );
      return Post.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Gets posts with pagination
  Future<List<Post>> getPosts({
    int page = 1,
    int limit = 10,
    String? userId,
  }) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (userId != null) 'user_id': userId,
        },
      );
      return (response.data['data'] as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Adds a comment to a post
  Future<void> addComment(String postId, String content) async {
    try {
      await _dio.post(
        '/posts/$postId/comments',
        data: {'content': content},
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Removes a comment from a post
  Future<void> removeComment(String postId, String commentId) async {
    try {
      await _dio.delete(
        '/posts/$postId/comments/$commentId',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Likes a post
  Future<void> likePost(String postId) async {
    try {
      await _dio.post(
        '/posts/$postId/likes',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Unlikes a post
  Future<void> unlikePost(String postId) async {
    try {
      await _dio.delete(
        '/posts/$postId/likes',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Gets a post by ID
  Future<Post> getPostById(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      return Post.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Saves a post
  Future<void> savePost(String postId) async {
    try {
      await _dio.post(
        '/posts/$postId/save',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Unsave a post
  Future<void> unsavePost(String postId) async {
    try {
      await _dio.delete(
        '/posts/$postId/save',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Gets saved posts
  Future<List<Post>> getSavedPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/posts/saved',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Updates a post through the API
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _dio.patch(
        '/posts/$postId',
        data: updates,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Removes a reply from a comment
  Future<void> removeReply(String commentId, String replyId) async {
    try {
      await _dio.delete(
        '/comments/$commentId/replies/$replyId',
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Adds a reply to a comment
  Future<void> addReply(String commentId, String content) async {
    try {
      await _dio.post(
        '/comments/$commentId/replies',
        data: {
          'content': content,
        },
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
}
