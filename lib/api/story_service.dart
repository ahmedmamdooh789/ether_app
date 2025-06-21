import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/story.dart';
import '../utils/api_error_handler.dart';

@injectable
class StoryService {
  final Dio _dio;

  StoryService(this._dio);

  Future<Story> createStory({
    required String mediaUrl,
    required bool isVideo,
    String? caption,
  }) async {
    try {
      final response = await _dio.post(
        '/stories',
        data: {
          'media_url': mediaUrl,
          'is_video': isVideo,
          if (caption != null) 'caption': caption,
        },
      );
      return Story.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<Story>> getStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/stories',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => Story.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Story> getStory(String storyId) async {
    try {
      final response = await _dio.get('/stories/$storyId');
      return Story.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Story> markStoryAsSeen(String storyId) async {
    try {
      final response = await _dio.post('/stories/$storyId/seen');
      return Story.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      await _dio.post('/stories/$storyId/views');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _dio.delete('/stories/$storyId');
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<Story>> getUserStories(String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$userId/stories',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => Story.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<List<Story>> getFriendsStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/stories/friends',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['data'] as List)
          .map((json) => Story.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
}
