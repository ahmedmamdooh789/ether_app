import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'story.g.dart';

@JsonSerializable()
class Story {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'user')
  final User user;
  
  @JsonKey(name: 'media_url')
  final String mediaUrl;
  
  @JsonKey(name: 'is_video')
  final bool isVideo;
  
  @JsonKey(name: 'caption')
  final String? caption;
  
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'views')
  final int views;
  
  @JsonKey(name: 'is_seen')
  final bool isSeen;
  
  Story({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.isVideo,
    this.caption,
    required this.expiresAt,
    required this.createdAt,
    this.views = 0,
    this.isSeen = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
  Map<String, dynamic> toJson() => _$StoryToJson(this);

  Story copyWith({
    String? id,
    User? user,
    String? mediaUrl,
    bool? isVideo,
    String? caption,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? views,
    bool? isSeen,
  }) {
    return Story(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isVideo: isVideo ?? this.isVideo,
      caption: caption ?? this.caption,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  bool get isViewed => isSeen;
}
