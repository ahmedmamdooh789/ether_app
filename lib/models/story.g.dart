// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      mediaUrl: json['media_url'] as String,
      isVideo: json['is_video'] as bool,
      caption: json['caption'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      views: (json['views'] as num?)?.toInt() ?? 0,
      isSeen: json['is_seen'] as bool? ?? false,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'media_url': instance.mediaUrl,
      'is_video': instance.isVideo,
      'caption': instance.caption,
      'expires_at': instance.expiresAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'views': instance.views,
      'is_seen': instance.isSeen,
    };
