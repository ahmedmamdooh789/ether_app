// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'profile_picture': instance.profilePicture,
      'bio': instance.bio,
      'created_at': instance.createdAt?.toIso8601String(),
      'last_seen': instance.lastSeen?.toIso8601String(),
    };
