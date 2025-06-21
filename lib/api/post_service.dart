import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/post.dart';
import '../utils/api_error_handler.dart';

@injectable
class PostService {
  final Dio _dio;

  PostService(this._dio);

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

  Future<Post> getPost(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      return Post.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _dio.post('/posts/$postId/likes');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _dio.delete('/posts/$postId/likes');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete('/posts/$postId');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<Post>> getUserFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/feed',
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
}
