import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../models/story.dart';
import '../api/story_service.dart';

@lazySingleton

@injectable
class StoryProvider extends ChangeNotifier {
  final StoryService _storyService;
  
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;
  
  StoryProvider(this._storyService);
  
  // Getters
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load stories
  Future<void> loadStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _stories = await _storyService.getStories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new story
  Future<bool> createStory({
    required String mediaUrl,
    required bool isVideo,
    String? caption,
    bool isSeen = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newStory = await _storyService.createStory(
        mediaUrl: mediaUrl,
        isVideo: isVideo,
        caption: caption,
      );
      _stories.insert(0, newStory);
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
  
  // Mark story as seen
  Future<void> markStoryAsSeen(String storyId) async {
    try {
      final index = _stories.indexWhere((story) => story.id == storyId);
      if (index == -1) return;
      
      // Mark as seen locally
      final story = _stories[index];
      if (!story.isSeen) {
        _stories[index] = story.copyWith(isSeen: true);
        notifyListeners();
        
        // Call API
        await _storyService.markStoryAsSeen(storyId);
      }
    } catch (e) {
      // Revert on error
      notifyListeners();
      rethrow;
    }
  }
  
  // Delete a story
  Future<bool> deleteStory(String storyId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _storyService.deleteStory(storyId);
      _stories.removeWhere((story) => story.id == storyId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
